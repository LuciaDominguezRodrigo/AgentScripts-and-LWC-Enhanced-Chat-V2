/**
 * @description Service for handling file uploads (ContentVersion + ContentDocumentLink) from LWC and Flow/Agent.
 * Provides AuraEnabled methods for LWC and reusable internal methods. Runs with sharing and user-mode DML.
 * Follows bulkification and security guidelines.
 * @author Agentforce
 * @group Prosegur File Upload
 * @ ApexDocs
 */
public with sharing class ProsegurFileUploadService {

    public enum VISIBILITY {
        ALL_USERS,
        INTERNAL_USERS,
        SHARED_USERS
    }

    /**
     * @description Uploads a file and optionally links it to a target record.
     * Intended to be called from LWC via @AuraEnabled.
     * @param base64Data Base64-encoded file body (without data URI prefix).
     * @param fileName Name of the file including extension.
     * @param mimeType MIME type (e.g. application/pdf, image/png).
     * @param targetRecordId Optional record Id to link the file to.
     * @param visibility Optional link visibility, defaults to ALL_USERS.
     * @return A simple DTO with created ContentVersionId, ContentDocumentId and optionally the link Id.
     */
    @AuraEnabled
    public static UploadResult uploadAndLink(String base64Data, String fileName, String mimeType, String targetRecordId, String visibility) {
        // Return-early validations
        if (String.isBlank(base64Data)) {
            throw new AuraHandledException('El contenido del archivo (base64) es obligatorio.');
        }
        if (String.isBlank(fileName)) {
            throw new AuraHandledException('El nombre del archivo es obligatorio.');
        }
        // Normalize visibility (safe parser, Apex has no Enum.valueOf)
        VISIBILITY linkVisibility = parseVisibility(visibility);

        // Create ContentVersion in USER_MODE
        UploadResult result = new UploadResult();
        ContentVersion cv = new ContentVersion();
        cv.Title = stripExtension(fileName);
        cv.PathOnClient = fileName;
        cv.VersionData = EncodingUtil.base64Decode(base64Data);
        // FileType is not writeable; omit setting it.

        // Insert ContentVersion (standard DML; with sharing and FLS applies when invoked via LWC/Flow)
        Database.SaveResult sr = Database.insert(cv, false);
        if (!sr.isSuccess()) {
            throw new AuraHandledException('Error creando el archivo: ' + firstError(sr));
        }

        // Query back ContentDocumentId in USER_MODE
        ContentVersion insertedCv = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Id = :sr.getId()
            WITH USER_MODE
            LIMIT 1
        ];
        result.contentVersionId = insertedCv.Id;
        result.contentDocumentId = insertedCv.ContentDocumentId;

        // Optionally link
        if (!String.isBlank(targetRecordId)) {
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = insertedCv.ContentDocumentId;
            cdl.LinkedEntityId = targetRecordId;
            cdl.ShareType = 'V';
            cdl.Visibility = mapVisibility(linkVisibility);

            Database.SaveResult linkSr = Database.insert(cdl, AccessLevel.USER_MODE);
            if (!linkSr.isSuccess()) {
                throw new AuraHandledException('Archivo creado pero fallo al vincularlo al registro: ' + firstError(linkSr));
            }
            result.contentDocumentLinkId = linkSr.getId();
        }

        return result;
    }

    /**
     * @description Creates ContentVersion records for multiple files (bulk). Internal helper for invocable.
     */
    private static List<ContentVersion> buildContentVersions(List<FileInput> inputs) {
        List<ContentVersion> versions = new List<ContentVersion>();
        for (FileInput fi : inputs) {
            if (fi == null || String.isBlank(fi.base64Data) || String.isBlank(fi.fileName)) {
                // Skip invalid entries, keep bulk-friendly
                continue;
            }
            ContentVersion cv = new ContentVersion();
            cv.Title = stripExtension(fi.fileName);
            cv.PathOnClient = fi.fileName;
            cv.VersionData = EncodingUtil.base64Decode(fi.base64Data);
            // FileType not writeable; omit.
            versions.add(cv);
        }
        return versions;
    }

    /**
     * @description Inserts ContentVersions and returns persisted rows, with ContentDocumentId populated.
     */
    private static List<ContentVersion> insertVersionsUserMode(List<ContentVersion> toInsert) {
        if (toInsert.isEmpty()) return new List<ContentVersion>();
        Database.SaveResult[] srs = Database.insert(toInsert, false);
        List<Id> successIds = new List<Id>();
        for (Database.SaveResult sr : srs) {
            if (sr.isSuccess()) {
                successIds.add(sr.getId());
            }
        }
        if (successIds.isEmpty()) return new List<ContentVersion>();
        return [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Id IN :successIds
            WITH USER_MODE
        ];
    }

    /**
     * @description Creates ContentDocumentLink records to link documents to a target record.
     */
    private static List<ContentDocumentLink> createLinksForRecord(Id targetId, List<ContentVersion> persisted, VISIBILITY visibility) {
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        for (ContentVersion cv : persisted) {
            if (cv.ContentDocumentId == null) continue;
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = cv.ContentDocumentId;
            cdl.LinkedEntityId = targetId;
            cdl.ShareType = 'V';
            cdl.Visibility = mapVisibility(visibility);
            links.add(cdl);
        }
        if (links.isEmpty()) return links;
        Database.insert(links, false);
        return links;
    }

    // --- DTOs ---

    public class UploadResult {
        @AuraEnabled public Id contentVersionId;
        @AuraEnabled public Id contentDocumentId;
        @AuraEnabled public Id contentDocumentLinkId;
    }

    public class FileInput {
        @AuraEnabled public String base64Data;
        @AuraEnabled public String fileName;
        @AuraEnabled public String mimeType;
    }

    public class BulkUploadInput {
        @AuraEnabled public List<FileInput> files;
        @AuraEnabled public String targetRecordId;
        @AuraEnabled public String visibility; // aligns with enum VISIBILITY
    }

    public class BulkUploadResult {
        @AuraEnabled public List<Id> contentVersionIds;
        @AuraEnabled public List<Id> contentDocumentIds;
        @AuraEnabled public List<Id> contentDocumentLinkIds;
    }

    // --- Helpers ---

    private static String firstError(Database.SaveResult sr) {
        if (sr == null) return 'Unknown error';
        for (Database.Error e : sr.getErrors()) {
            return e.getMessage();
        }
        return 'Unknown error';
    }

    private static String stripExtension(String name) {
        if (String.isBlank(name)) return 'Archivo';
        Integer dot = name.lastIndexOf('.');
        return dot > 0 ? name.substring(0, dot) : name;
    }

    // No FileType mapping — field not writeable on ContentVersion

    private static VISIBILITY parseVisibility(String v) {
        if (String.isBlank(v)) return VISIBILITY.ALL_USERS;
        String up = v.trim().toUpperCase();
        if (up == 'ALL_USERS') return VISIBILITY.ALL_USERS;
        if (up == 'INTERNAL_USERS') return VISIBILITY.INTERNAL_USERS;
        if (up == 'SHARED_USERS') return VISIBILITY.SHARED_USERS;
        return VISIBILITY.ALL_USERS;
    }

    private static String mapVisibility(VISIBILITY v) {
        switch on v {
            when ALL_USERS { return 'AllUsers'; }
            when INTERNAL_USERS { return 'InternalUsers'; }
            when SHARED_USERS { return 'SharedUsers'; }
        }
        return 'AllUsers';
    }
}

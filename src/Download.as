const string MasterServerStorageUrl = "https://prod.trackmania.core.nadeo.online/storageObjects/";

// The categories to group the overlay into
// remember to change the amount of buckets in Overlay.as if this is changed
enum FileType {
    Map = 0,
    Mod = 1,
    MediaTracker = 2, // /Media/ - Is used in MT
    Model = 3,
    MapSkin = 4,
    Other = 5
}

// class that the cache contains, here we save data that needs to be computed and wont change
class FileTransferDownload {

    // if you are asking yourself why I dont have a m_download handle so the class contains the download and check for null, that isnt possible because of uninitialized pointers / references
    string m_fileName = "???";
    FileType m_fileType = FileType::Other;
    string m_detailFileType = "???";

    FileTransferDownload(CNetFileTransferDownload@ Download) {
        m_fileName = TransferDownload::GetFileName(Download);
        m_fileType = TransferDownload::GetFileType(Download);
        m_detailFileType = TransferDownload::GetDetailedFileType(Download);
    }
}

// previously class methods but since download nods were inconsistent in memory we take em as parameters now
namespace TransferDownload {
    // might have a different result if called during active download but we cache when we see it so
    string GetURL(CNetFileTransferDownload@ Download) {
        if (Download.Url == "") return Download.LastUrlUsed;
        return Download.Url;
    }

    // 90% certain this is semantically correct
    bool IsInQueue(CNetFileTransferDownload@ Download) {
        return Download.NbOfEffectiveSources > 0;
    }

    // get progress of download if there is any
    float GetProgress(CNetFileTransferDownload@ Download) {
        uint[] progress = GetTransferState(Download);
        if (progress[1] == 0) return 0.;
        return float(progress[0]) / float(progress[1]);
    }

    // parse resulting file path in game data dir to name
    string GetFileName(CNetFileTransferDownload@ Download) {
        array<string> path = string(Download.Name).Split("\\");
        if (GetURL(Download).StartsWith(MasterServerStorageUrl)) {
            string storageObjectId = GetURL(Download).SubStr(MasterServerStorageUrl.Length);
            return path[path.Length - 1].Replace(storageObjectId, "");
        }
        return path[path.Length - 1];
    }

    // parse resulting file path in game data dir to bucket type
    FileType GetFileType(CNetFileTransferDownload@ Download) {
        array<string> gameDataPath = string(Download.Name).Split("\\");
        if (gameDataPath[0] == "Maps") return FileType::Map;
        if (gameDataPath[0] == "Skins") {
            try {
                if (gameDataPath[1] == "Stadium") {
                    if (gameDataPath[2] == "Mod") return FileType::Mod;
                    return FileType::MapSkin;
                }
                if (gameDataPath[1] == "Any") return FileType::MapSkin;
                if (gameDataPath[1] == "Models") return FileType::Model;
            } catch {
                error(getExceptionInfo());
            }
        }
        if (gameDataPath[0] == "Media") return FileType::MediaTracker;
        return FileType::Other;
    }

    // parse resulting file path in game data dir to subfolder name as type
    string GetDetailedFileType(CNetFileTransferDownload@ Download) {
        array<string> gameDataPath = string(Download.Name).Split("\\");
        if (gameDataPath[0] == "Maps") return "Map";
        if (gameDataPath[0] == "Skins") {
            try {
                if (gameDataPath[1] == "Any") return gameDataPath[2].Replace("Advertisement", "Sign");
                if (gameDataPath[1] == "Models") return gameDataPath[2];
                if (gameDataPath[1] == "Stadium") return gameDataPath[2];
            } catch {
                error(getExceptionInfo());
            }
            return "Skin";
        }
        if (gameDataPath[0] == "Media") {
            try {
                return gameDataPath[1].EndsWith("s") ? gameDataPath[1].SubStr(0,gameDataPath[1].Length - 1) : gameDataPath[1];
            } catch {
                error(getExceptionInfo());
            }
        }
        return gameDataPath[0];
    }

    uint[] GetTransferState(CNetFileTransferDownload@ Download) {
        if (Download.ActiveUrlSource !is null && cast<CNetMasterServerDownload>(Download.ActiveUrlSource.MasterServerDownload) !is null && cast<CNetMasterServerDownload>(Download.ActiveUrlSource.MasterServerDownload).HttpResult !is null) {
            return {cast<CNetMasterServerDownload>(Download.ActiveUrlSource.MasterServerDownload).HttpResult.CurrentSize, cast<CNetMasterServerDownload>(Download.ActiveUrlSource.MasterServerDownload).HttpResult.ExpectedTransfertSize};
        }
        if (Download.ActiveSource !is null && Download.ActiveSource.Download !is null) {
            return {Download.ActiveSource.Download.CurrentOffset, Download.ActiveSource.Download.TotalSize};
        }
        return {Download.CurrentOffset, Download.TotalSize};
    }
}
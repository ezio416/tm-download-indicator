CNetFileTransfer@ g_fileTransfer;
dictionary g_downloadCache;
bool g_previousPlayground = false;
int g_font;
uint64 g_nextCacheUpdate;

void Main() {
    g_font = nvg::LoadFont("DroidSans.ttf", true);
}

void Render() {
    @g_fileTransfer = GetApp().Network.FileTransfer;
    if (g_fileTransfer is null) return;
    // Make sure every download is cached
    ManageDownloadCache();
    UpdateDownloads();
    // Render overlay
    Overlay::Render();
}

void RenderInterface() {    
    if (Setting_OverlayLocator) {
        vec2 screenSize = vec2(Draw::GetWidth(), Draw::GetHeight());
        Locator::Render("Example Progress bar", Setting_OverlayPos, GetOverlayBarSizeAbsolute());
        Setting_OverlayPos = Locator::GetPos();
        Setting_OverlayBarSize = Locator::GetSize() / screenSize;
        ProgressBar::Render(GetOverlayPosAdjusted(), GetOverlayBarSizeAbsolute(), vec3(1., 1., 1.), 1., "", "", "");
    }
}

void RenderMenu() {
    if (UI::MenuItem("\\$f39" + Icons::Kenney::Download + "\\$fff  Download Indicator", "", g_showAdvancedWindow)) {
        g_showAdvancedWindow = !g_showAdvancedWindow;
    }
}

void UpdateDownloads() {
    for (uint i = 0; i < g_fileTransfer.Downloads.Length; i++) {
        // cache download data if nonexistant
        string idKey = tostring(g_fileTransfer.Downloads[i].IdDownload);
        if (!g_downloadCache.Exists(idKey)) {
            g_downloadCache.Set(idKey, @FileTransferDownload(g_fileTransfer.Downloads[i]));
        }
    }

    for (uint i = 0; i < g_fileTransfer.TerminatedDownloads.Length; i++) {
        // cache terminated download data if nonexistant
        string idKey = tostring(g_fileTransfer.TerminatedDownloads[i].IdDownload);
        if (!g_downloadCache.Exists(idKey)) {
            g_downloadCache.Set(idKey, @FileTransferDownload(g_fileTransfer.TerminatedDownloads[i]));
        }
    }
}

void ManageDownloadCache() {
    if (Time::Now < g_nextCacheUpdate) return;
    g_nextCacheUpdate = Time::Now + 3000;

    // only run this when the playground has been exited
    if (GetApp().CurrentPlayground is null && g_previousPlayground) {
        uint i = 0;
        array<string> itemsToRemove = g_downloadCache.GetKeys();

        while (i < itemsToRemove.Length) {
            bool found = false;
            for (uint j = 0; j < g_fileTransfer.Downloads.Length; j++) {
                if (tostring(g_fileTransfer.Downloads[j].IdDownload) == itemsToRemove[i]) {
                    found = true;
                    break;
                }
            }

            // Nod of cache ID has been found in Downloads buffer
            if (found) {
                i++;
                continue;
            }

            for (uint j = 0; j < g_fileTransfer.TerminatedDownloads.Length; j++) {
                if (tostring(g_fileTransfer.TerminatedDownloads[j].IdDownload) == itemsToRemove[i]) {
                    found = true;
                    break;
                }
            }
            
            // Nod of cache ID has been found in TerminatedDownloads buffer
            if (found) {
                i++;
                continue;
            }

            // Nod doesnt exist anymore, remove
            itemsToRemove.RemoveAt(i);
        }
    }

    g_previousPlayground = (GetApp().CurrentPlayground !is null);
}
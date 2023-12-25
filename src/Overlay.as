const string g_DisabledColor = "\\$777";
const array<string> DownloadStates = {"Waiting for Sources", "Processing Sources", "Waiting for Termination", "Terminating", "Done"};
bool g_showAdvancedWindow;

// namespace for methods to be called from main
namespace Overlay {

    void Render() {
        // accumulate active downloads into buckets by type
        vec2 currentCursor = GetOverlayPosAdjusted();
        for (int i = 0; i < 6; i++) { // 6 == File type enum size
            string typeIcon = "";
            vec3 color;
            if (i == FileType::Map) {
                if (!Setting_ShowMapDownloads) continue;
                else {
                    typeIcon = Icons::Map;
                    color = Setting_MapDownloadColor;
                }
            } else if (i == FileType::Mod) {
                if (!Setting_ShowModDownloads) continue;
                else {
                    typeIcon = Icons::PaintBrush;
                    color = Setting_ModDownloadColor;
                }
            } else if (i == FileType::MediaTracker) {
                if (!Setting_ShowMediaDownloads) continue;
                else {
                    typeIcon = Icons::Film;
                    color = Setting_MediaDownloadColor;
                }
            } else if (i == FileType::Model) {
                if (!Setting_ShowModelDownloads) continue;
                else {
                    typeIcon = Icons::Car;
                    color = Setting_ModelDownloadColor;
                }
            } else if (i == FileType::MapSkin) {
                if (!Setting_ShowMapSkinDownloads) continue;
                else {
                    typeIcon = Icons::MapSigns;
                    color = Setting_MapSkinDownloadColor;
                }
            } else if (i == FileType::Other) {
                if (!Setting_ShowOtherDownloads) continue;
                else {
                    typeIcon = Icons::Question;
                    color = Setting_OtherDownloadColor;
                }
            }

            uint downloadsInProgress = 0;

            uint[] maxDownloadData = {0,0};
            float maxProgress = 0;

            uint[] currentDownloadData = {0,0};
            float currentProgress = 0;

            // go through all downloads, check if they are active and take progress values for bucket
            for (uint j = 0; j < g_fileTransfer.Downloads.Length; j++) {
                if (cast<FileTransferDownload>(g_downloadCache[tostring(g_fileTransfer.Downloads[j].IdDownload)]).m_fileType != i) continue;
                if (!TransferDownload::IsInQueue(g_fileTransfer.Downloads[j]) && !Setting_ShowInactiveDownloads) continue;
                downloadsInProgress++;
                currentDownloadData = TransferDownload::GetTransferState(g_fileTransfer.Downloads[j]);
                if (currentDownloadData[1] == 0) currentProgress = 0;
                else currentProgress = float(currentDownloadData[0]) / float(currentDownloadData[1]);
                if (currentProgress > maxProgress) {
                    maxProgress = currentProgress;
                    maxDownloadData = currentDownloadData;
                }
            }

            // failsafe in case of memory instability reading values > 1
            maxProgress = Math::Min(maxProgress, 1.);

            // if there are downloads of this bucket that are active, we render this bucket's bar
            if (downloadsInProgress > 0) {
                string downloadDisplay = "";
                if (Setting_ShowDownloadProgressShorthand == DownloadProgressSummary::DownloadProgress) {
                    downloadDisplay = Math::Round(100.0 * maxProgress) + "%";
                } else if (Setting_ShowDownloadProgressShorthand == DownloadProgressSummary::DownloadSize) {
                    downloadDisplay = Text::FormatSize(maxDownloadData[0], 1) + " / " + Text::FormatSize(maxDownloadData[1], 1);
                }
                ProgressBar::Render(currentCursor, GetOverlayBarSizeAbsolute(), color, maxProgress, typeIcon, downloadDisplay, tostring(downloadsInProgress));
                
                // bar tooltip on hover
                if (UI::GetMousePos().x > currentCursor.x && UI::GetMousePos().x < currentCursor.x + GetOverlayBarSizeAbsolute().x && UI::GetMousePos().y > currentCursor.y && UI::GetMousePos().y < currentCursor.y + GetOverlayBarSizeAbsolute().y) {
                    UI::BeginTooltip();
                    for (uint j = 0; j < g_fileTransfer.Downloads.Length; j++) {
                        if (cast<FileTransferDownload>(g_downloadCache[tostring(g_fileTransfer.Downloads[j].IdDownload)]).m_fileType != i) continue;
                        if (!TransferDownload::IsInQueue(g_fileTransfer.Downloads[j]) && !Setting_ShowInactiveDownloads) continue;
                        UI::SetNextItemWidth(150);
                        UI::LabelText(cast<FileTransferDownload>(g_downloadCache[tostring(g_fileTransfer.Downloads[j].IdDownload)]).m_fileName, FormulateProgressSize(g_fileTransfer.Downloads[j]));
                    }
                    UI::EndTooltip();
                }
                currentCursor.y += (Setting_OverlayPos.y > 0.5 ? -1 : 1) * 1.2 * GetOverlayBarSizeAbsolute().y;
            }
        }

        // also render completed downloads number
        if (Setting_ShowCompletedDownloads && g_fileTransfer.TerminatedDownloads.Length > 0) {
            uint terminatingDownloads = 0;
            for (uint j = 0; j < g_fileTransfer.TerminatedDownloads.Length; j++) {
                if (g_fileTransfer.TerminatedDownloads[j].DownloadState != 3) continue;
                terminatingDownloads++;
            }

            // only render bar if necessary, as before
            if (terminatingDownloads > 0) {
                ProgressBar::Render(currentCursor, GetOverlayBarSizeAbsolute(), Setting_CompletedDownloadColor, 0., Icons::Check, "", tostring(terminatingDownloads));
                if (UI::GetMousePos().x > currentCursor.x && UI::GetMousePos().x < currentCursor.x + GetOverlayBarSizeAbsolute().x && UI::GetMousePos().y > currentCursor.y && UI::GetMousePos().y < currentCursor.y + GetOverlayBarSizeAbsolute().y) {
                    UI::BeginTooltip();
                    for (uint j = 0; j < g_fileTransfer.TerminatedDownloads.Length; j++) {
                        UI::Text(cast<FileTransferDownload>(g_downloadCache[tostring(g_fileTransfer.TerminatedDownloads[j].IdDownload)]).m_fileName + " (" + g_fileTransfer.TerminatedDownloads[j].DownloadState + ")");
                    }
                    UI::EndTooltip();
                }
            }
        }

        if (g_showAdvancedWindow && UI::IsOverlayShown()) {
            RenderAdvancedWindow();
        }
    }

    // Advanced display main method, called from Main.as
    void RenderAdvancedWindow() {
        if (UI::Begin("\\$f39" + Icons::Kenney::Download + "\\$fff  Download Indicator \\$555 by Nsgr###DownloadIndicator", g_showAdvancedWindow)) {
    		UI::BeginTabBar("DLTabBar", UI::TabBarFlags::FittingPolicyResizeDown);
            if (UI::BeginTabItem("Downloads")) {
                RenderDownloadTable(g_fileTransfer.Downloads, "Downloads");
                UI::EndTabItem();
            }
            if (UI::BeginTabItem("Terminated Downloads")) {
                if (UI::IsItemHovered()) {
                    UI::BeginTooltip();
                    UI::Text("Pause to complete terminated downloads");
                    UI::EndTooltip();
                }
                RenderDownloadTable(g_fileTransfer.TerminatedDownloads, "TerminatedDownloads");
                UI::EndTabItem();
            }
            UI::EndTabBar();
    		UI::End();
    	}
    }
}

// Abstraction for table
void RenderDownloadTable(MwFastBuffer<CNetFileTransferDownload@> Downloads, const string &in ID) {
    if (UI::BeginTable(ID, 5, UI::TableFlags::ScrollY)) {
        UI::PushStyleColor(UI::Col::PopupBg, vec4(0.1,0.1,0.1,1.0));
        UI::TableSetupScrollFreeze(0, 1);
        UI::TableSetupColumn("State", UI::TableColumnFlags::WidthFixed, 64);
        UI::TableSetupColumn("File", UI::TableColumnFlags::WidthStretch);
        UI::TableSetupColumn("Type", UI::TableColumnFlags::WidthFixed, 128);
        UI::TableSetupColumn("Sources", UI::TableColumnFlags::WidthFixed, 64);
        UI::TableSetupColumn("Progress", UI::TableColumnFlags::WidthFixed, 64);
        UI::TableHeadersRow();
        UI::ListClipper Clipper(Downloads.Length);
        while (Clipper.Step()) {
            for (int i = Clipper.DisplayStart; i < Clipper.DisplayEnd; i++) {
                UI::TableNextRow();
                RenderDownloadRow(Downloads[i], ID + i);
            }
        }
        UI::PopStyleColor(1);
        UI::EndTable();
    }
}

// Abstraction for a single download object
void RenderDownloadRow(CNetFileTransferDownload@ Download, const string &in ID) {
    UI::PushID(ID);
    UI::TableSetColumnIndex(0);RenderDownloadState(Download); // State in the form of arrows
    UI::TableSetColumnIndex(1);RenderDownloadFile(Download); // Filename after parsing
    UI::TableSetColumnIndex(2);RenderDownloadType(Download); // Filetype after parsing
    UI::TableSetColumnIndex(3);RenderDownloadSources(Download); // Quick display of sources (TODOL: Active source state in tooltip)
    UI::TableSetColumnIndex(4);RenderDownloadProgress(Download); // Progress as % (with absolute values on hovering)
    UI::PopID();
}

// State cell for download row
void RenderDownloadState(CNetFileTransferDownload@ Download) {
    string State = g_DisabledColor;
    for (uint i = 0; i < 5; i++) {
        if (Download.DownloadState == i) {
            State += "\\$1f1" + Icons::AngleDoubleRight + g_DisabledColor;
        } else {
            State += Icons::AngleDoubleRight;
        }
    }
    UI::Text(State);
    if (UI::IsItemHovered()) {
        UI::BeginTooltip();
        for (uint i = 0; i < 5; i++) { // 5 == download state enum size
            string prefix = g_DisabledColor;
            if (Download.DownloadState == i) {
                prefix = "\\$fff";
            }
            UI::Text(prefix + DownloadStates[i]);
        }
        UI::EndTooltip();
    }
}

// File(name) cell for download row
void RenderDownloadFile(CNetFileTransferDownload@ Download) {
    UI::Text(cast<FileTransferDownload@>(g_downloadCache[tostring(Download.IdDownload)]).m_fileName);
    if (UI::IsItemHovered()) { // Display file stuff info as tooltip
        UI::BeginTooltip();
        float tooltipSize = 10 + Draw::MeasureString("Checksum"+Download.Checksum).x;
        UI::SetNextItemWidth(tooltipSize);
        UI::LabelText("File",Download.Name);
        UI::SetNextItemWidth(tooltipSize);
        UI::LabelText("Url",TransferDownload::GetURL(Download));
        UI::SetNextItemWidth(tooltipSize);
        UI::LabelText("Checksum",Download.Checksum);
        UI::SetNextItemWidth(tooltipSize);
        UI::LabelText("TempFile",Download.TempFileName);
        UI::EndTooltip();
    }
}

// Type cell for download row
void RenderDownloadType(CNetFileTransferDownload@ Download) {
    UI::Text(cast<FileTransferDownload@>(g_downloadCache[tostring(Download.IdDownload)]).m_detailFileType);
}

// Sources cell for download row
void RenderDownloadSources(CNetFileTransferDownload@ Download) {
    int ActiveSources = 0;
    if (Download.ActiveSource !is null) ActiveSources++;
    if (Download.ActiveUrlSource !is null) ActiveSources++;
    UI::Text(g_DisabledColor + HighlightIfNotZero(ActiveSources) + ":" + HighlightIfNotZero(Download.NbOfEffectiveSources) + ":" + HighlightIfNotZero(Download.UrlSources.Length) + ":" + HighlightIfNotZero(Download.Sources.Length));
    if (UI::IsItemHovered()) {
        UI::BeginTooltip();
        UI::Text("Active Sources : Effective Sources : Url Sources : Sources");
        UI::EndTooltip();
    }
}

// Helper function for sources cell
string HighlightIfNotZero(int num) {
    if (num != 0) {
        return "\\$fff" + num + g_DisabledColor;
    }
    return tostring(num);
}

// Progress cell for download row
void RenderDownloadProgress(CNetFileTransferDownload@ Download) {
    UI::Text(FormulateProgress(Download));
    if (UI::IsItemHovered()) {
        UI::BeginTooltip();
        UI::SetNextItemWidth(150);
        UI::LabelText("Progress", FormulateProgressSize(Download));
        UI::EndTooltip();
    }
}

// Helper function for progress cell
// Example: 46%
string FormulateProgress(CNetFileTransferDownload@ Download) {
    uint[] progress = TransferDownload::GetTransferState(Download);
    return FormulatePercent(progress[0], progress[1]);
}

// Helper function for progress cell
string FormulatePercent(int a, int b) {
    if (a == b) {
        if (a == 0) return g_DisabledColor + "0%";
        return g_DisabledColor + "100%";
    }
    if (b == 0) return a + "!";
    return int(100.0 * (float(a) / float(b))) + "%";
}

// Helper function for progress bar hovering
// Example: 126.32 KB / 280.23KB
string FormulateProgressSize(CNetFileTransferDownload@ Download) {
    uint[] progress = TransferDownload::GetTransferState(Download);
    return Text::FormatSize(progress[0]) + " / " + Text::FormatSize(progress[1]);
}
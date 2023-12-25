[Setting category="Overlay" name="Enable Locator mode"]
bool Setting_OverlayLocator = false;

[Setting category="Overlay" name="Position"]
vec2 Setting_OverlayPos = vec2(0.0,0.123);

vec2 GetOverlayPosAdjusted() {
    return Setting_OverlayPos * (vec2(Draw::GetWidth(), Draw::GetHeight()) - GetOverlayBarSizeAbsolute());
}

[Setting category="Overlay" name="Bar size"]
vec2 Setting_OverlayBarSize = vec2(0.08, 0.025);

vec2 GetOverlayBarSizeAbsolute() {
    return vec2(Draw::GetWidth() * Setting_OverlayBarSize.x, Draw::GetHeight() * Setting_OverlayBarSize.y);
}

[Setting category="Overlay" name="Bar rounding" min=0 max=1]
float Setting_OverlayBarRounding = 0.5;


[Setting category="Downloads" name="Show Map downloads"]
bool Setting_ShowMapDownloads = true;

[Setting category="Downloads" name="Map download Color" color]
vec3 Setting_MapDownloadColor = vec3(1.000f, 0.761f, 0.188f);

[Setting category="Downloads" name="Show Mod downloads"]
bool Setting_ShowModDownloads = true;

[Setting category="Downloads" name="Mod download color" color]
vec3 Setting_ModDownloadColor = vec3(0.664f, 1.000f, 0.184f);

[Setting category="Downloads" name="Show Media downloads"]
bool Setting_ShowMediaDownloads = true;

[Setting category="Downloads" name="Media download color" color]
vec3 Setting_MediaDownloadColor = vec3(0.184f, 1.000f, 0.856f);

[Setting category="Downloads" name="Show Model downloads"]
bool Setting_ShowModelDownloads = true;

[Setting category="Downloads" name="Model download color" color]
vec3 Setting_ModelDownloadColor = vec3(0.184f, 0.568f, 1.000f);

[Setting category="Downloads" name="Show Block / Item Skin downloads"]
bool Setting_ShowMapSkinDownloads = true;

[Setting category="Downloads" name="Block / Item Skin download color" color]
vec3 Setting_MapSkinDownloadColor = vec3(0.376f, 0.184f, 1.000f);

[Setting category="Downloads" name="Show Other / Unknown downloads"]
bool Setting_ShowOtherDownloads = true;

[Setting category="Downloads" name="Other / Unknown download color" color]
vec3 Setting_OtherDownloadColor = vec3(0.952f, 0.184f, 1.000f);

[Setting category="Downloads" name="Show number of completed downloads" description="These downloads will put the media in your game when you pause the game (or stop the playing state)"]
bool Setting_ShowCompletedDownloads = true;

[Setting category="Downloads" name="Completed Downloads bar color" color]
vec4 Setting_CompletedDownloadColor = vec4(0.5, 0.5, 0.5, 0.5);


[Setting category="Advanced" name="Include inactive downloads"]
bool Setting_ShowInactiveDownloads = false;

enum DownloadProgressSummary {
    DownloadSize,
    DownloadProgress,
    Off
}

[Setting category="Advanced" name="Centered bar label" description="The information that is displayed in the center of a progress bar."]
DownloadProgressSummary Setting_ShowDownloadProgressShorthand = DownloadProgressSummary::DownloadProgress;


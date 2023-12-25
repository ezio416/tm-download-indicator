namespace ProgressBar {
    void Render(vec2 pos, vec2 size, vec3 color, float progress, const string &in left, const string &in center, const string &in right) {
        Render(pos, size, vec4(color.x, color.y, color.z, 1.0), progress, left, center, right);
    }

    void Render(vec2 pos, vec2 size, vec4 color, float progress, const string &in left, const string &in center, const string &in right) {
        float roundingMax = Math::Min(size.x, size.y) * 0.5;
        float rounding = roundingMax * Setting_OverlayBarRounding;
        float textRounding = roundingMax * Math::Max(0.4, Setting_OverlayBarRounding);
        nvg::FontFace(g_font);

        // Bar background
        nvg::BeginPath();
        nvg::FillColor(vec4(color.x * 0.3, color.y * 0.3, color.z * 0.3, color.w));
        nvg::RoundedRect(pos.x, pos.y, size.x, size.y, rounding);
        nvg::Fill();

        // bar foreground (only drawn when enough progress exists)
        if (progress > 0.01) {
            nvg::BeginPath();
            nvg::FillColor(vec4(color.x, color.y, color.z, color.w));
            nvg::RoundedRect(pos.x, pos.y, progress * size.x, size.y, rounding);
            nvg::Fill();
        }

        // texts
        nvg::BeginPath();
        nvg::FillColor(vec4(1,1,1,1));
        nvg::FontSize(size.y * 0.5);

        if (left != "") {
            nvg::TextAlign(nvg::Align::Left | nvg::Align::Middle);
            nvg::Text(pos.x + textRounding, pos.y + size.y * 0.5, left);
        }

        if (center != "") {
            nvg::TextAlign(nvg::Align::Center | nvg::Align::Middle);
            nvg::Text(pos.x + size.x * 0.5, pos.y + size.y * 0.5, center);
        }
        
        if (right != "") {
            nvg::TextAlign(nvg::Align::Right | nvg::Align::Middle);
            nvg::Text(pos.x + size.x - textRounding, pos.y + size.y * 0.5, right);
        }
    }
}
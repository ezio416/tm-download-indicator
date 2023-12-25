namespace Text {
    string FormatSize(int bytes, uint decimals) {
        string[] sizes = { "B", "KB", "MB", "GB" };
        double len = bytes;
        uint order = 0;
        while (len >= 1024 && order < sizes.Length - 1) {
            order++;
            len = len/1024;
        }
        return Text::Format("%." + tostring(decimals) + "f", len) + sizes[order];
    }

    string FormatSize(int bytes) {
        return FormatSize(bytes, 2);
    }
}
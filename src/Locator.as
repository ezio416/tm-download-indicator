namespace Locator
{
	vec2 g_pos;
	vec2 g_size;

	void Render(const string &in name, const vec2 &in settingPos, const vec2 &in settingSize)
	{
		vec2 screenSize = vec2(Draw::GetWidth() / UI::GetScale(), Draw::GetHeight() / UI::GetScale());
		vec2 pos = settingPos * (screenSize - settingSize);

		UI::SetNextWindowSize(int(settingSize.x), int(settingSize.y), UI::Cond::Appearing);
		UI::SetNextWindowPos(int(pos.x), int(pos.y), UI::Cond::Appearing);

		UI::Begin(Icons::ArrowsAlt + " Locator: " + name, UI::WindowFlags::NoCollapse | UI::WindowFlags::NoSavedSettings | UI::WindowFlags::NoDocking);
		g_size = UI::GetWindowSize() / vec2(UI::GetScale(), UI::GetScale());
		g_pos = UI::GetWindowPos() / (screenSize - g_size) / vec2(UI::GetScale(), UI::GetScale());
		UI::End();
	}

	vec2 GetPos() { return g_pos; }
	vec2 GetSize() { return g_size; }
}

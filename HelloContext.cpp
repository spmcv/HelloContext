#include <sstream>
#include <Core/CoreAll.h>
#include <Fusion/FusionAll.h>
#include <CAM/CAMAll.h>
#include <nlohmann/json.hpp>


using namespace adsk::core;
using namespace adsk::fusion;
using namespace adsk::cam;

using sstream = std::stringstream;
using json = nlohmann::json;


Ptr<Application> app;
Ptr<UserInterface> ui;


bool parse(const char* context, const char *key)
{
    bool value;
    json parsed;
    sstream message;

    try {
        parsed = json::parse(context);
    } catch (json::parse_error &error) {
        message << "error while parsing 'context':";
        message << std::endl;
        message << error.what();
        ui->messageBox(message.str(), "Error");
        return false;
    }

    ui->messageBox(parsed.dump(4), "Parsed JSON");

    try {
        value = parsed.at(key);
    } catch (json::out_of_range &error) {
        message << "error while accessing 'context':";
        message << std::endl;
        message << error.what();
        ui->messageBox(message.str(), "Error");
        return false;
    }

    message << "context key ";
    message << "'" << key << "'";
    message << " has value ";
    message << std::boolalpha;
    message << "'" << value << "'";
    ui->messageBox(message.str(), "Success");
    return true;
}


extern "C" XI_EXPORT bool run(const char* context)
{
    app = Application::get();
    if (!app)
        return false;

    ui = app->userInterface();
    if (!ui)
        return false;

    return parse(context, "IsApplicationStartup");
}

extern "C" XI_EXPORT bool stop(const char* context)
{
    if (!app)
        return false;

    if (!ui)
        return false;

    return parse(context, "IsApplicationClosing");
}

#ifdef XI_WIN

#include <windows.h>

BOOL APIENTRY DllMain(HMODULE hmodule, DWORD reason, LPVOID reserved)
{
	switch (reason)
	{
	case DLL_PROCESS_ATTACH:
	case DLL_THREAD_ATTACH:
	case DLL_THREAD_DETACH:
	case DLL_PROCESS_DETACH:
		break;
	}
	return TRUE;
}

#endif // XI_WIN

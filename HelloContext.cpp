#include <sstream>
#include <Core/CoreAll.h>
#include <Fusion/FusionAll.h>
#include <CAM/CAMAll.h>
#include <nlohmann/json.hpp>


using namespace std;
using namespace adsk::core;
using namespace adsk::fusion;
using namespace adsk::cam;

using json = nlohmann::json;


Ptr<Application> app;
Ptr<UserInterface> ui;


const string parseContext(const char* context, const char* key) {

    stringstream ss;

    auto asJsonObject = json::parse(context);

    ss << "parsed 'context' arg as:";
    ss << "\n\n";
    ss << asJsonObject.dump(4) ;
    ss <<  "\n\n";
    ss << "contains key " << key << " is ";
    ss << asJsonObject.contains(key);

    return ss.str();
}


extern "C" XI_EXPORT bool run(const char* context)
{

    app = Application::get();
    if (!app)
        return false;

    ui = app->userInterface();
    if (!ui)
        return false;

    try {
        ui->messageBox(parseContext(context, "isApplicationStartup"));
    } catch (json::parse_error error) {
        ui->messageBox(error.what(), "Failed to parse 'context'");
    }

    return true;
}

extern "C" XI_EXPORT bool stop(const char* context)
{

    if (!app)
        return false;

    if (!ui)
        return false;

    try {
        ui->messageBox(parseContext(context, "isApplicationClosing"));
    } catch (json::parse_error error) {
        ui->messageBox(error.what(), "Failed to parse 'context'");
    }

    return true;
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

import { CodeBlock } from "@/components/CodeBlock";
import { PageHeader, InfoBox } from "@/components/DocComponents";

export default function Installation() {
  return (
    <div className="max-w-4xl mx-auto px-8 py-12">
      <PageHeader
        title="Installation"
        description="How to install and set up the Seisen UI library in your scripts."
      />

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Loading the Library</h2>
        <p className="text-[#a0a0a0] mb-4">
          Seisen UI is loaded directly from GitHub. Add this code at the top of your script:
        </p>
        <CodeBlock
          title="loader.lua"
          code={`local Repo = "https://raw.githubusercontent.com/Ken-884/Seisen-Library/main/"

-- Load the main library
local Library = loadstring(game:HttpGet(Repo .. "SeisenUI.lua"))()

-- Optional: Load addons
local ThemeManager = loadstring(game:HttpGet(Repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(Repo .. "addons/SaveManager.lua"))()`}
        />
      </section>

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Setting Up Addons</h2>
        <p className="text-[#a0a0a0] mb-4">
          If you want to use ThemeManager and SaveManager, you need to configure them:
        </p>
        <CodeBlock
          code={`-- After creating your Window and Tabs...

-- Connect the addons to the library
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

-- Configure SaveManager
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

-- Set save folders
ThemeManager:SetFolder("YourScriptName")
SaveManager:SetFolder("YourScriptName/configs")

-- Build the UI sections in your Settings tab
ThemeManager:BuildThemeSection(SettingsTab)
SaveManager:BuildConfigSection(SettingsTab)`}
        />
      </section>

      <InfoBox type="info">
        <strong>Note:</strong> The library automatically handles CoreGui/PlayerGui placement based on 
        whether you&apos;re in Studio or in-game.
      </InfoBox>

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Local Development</h2>
        <p className="text-[#a0a0a0] mb-4">
          If you want to test local changes to the library, you can load it from a file:
        </p>
        <CodeBlock
          code={`-- Option 1: Load from file (requires readfile support)
local Library = loadstring(readfile("YourFolder/SeisenUI.lua"))()

-- Option 2: Paste the library code directly into your script`}
        />
      </section>
    </div>
  );
}

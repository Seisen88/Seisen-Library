import { CodeBlock } from "@/components/CodeBlock";
import { ConfigTable } from "@/components/ConfigTable";
import { PageHeader, MethodCard, InfoBox } from "@/components/DocComponents";

export default function SaveManager() {
  return (
    <div className="max-w-4xl mx-auto px-8 py-12">
      <PageHeader
        title="SaveManager"
        description="Built-in system for saving and loading configuration profiles."
      />

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Setup</h2>
        <p className="text-[#a0a0a0] mb-4">
          The SaveManager allows users to create multiple config profiles. You typically add it to a dedicated "Settings" tab.
        </p>
        <CodeBlock
          code={`local SaveManager = Library.SaveManager
-- Set the folder where configs will be saved
SaveManager:SetLibrary(Library)
SaveManager:SetFolder("MyScript/Configs")

-- Create a settings tab
local SettingsTab = Window:AddTab("Settings", "Configuration", "settings")

-- Add the SaveManager UI to the right side
local ConfigSection = SettingsTab:AddRightSection("Configuration")
SaveManager:BuildConfigSection(ConfigSection)`}
        />
      </section>

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Methods</h2>
        
        <MethodCard
          name="SaveManager:SetFolder(path)"
          description="Sets the folder path for saving configurations."
          params="path: string (e.g. 'MyGame/ScriptName')"
          returns="void"
        />

        <MethodCard
          name="SaveManager:SetLibrary(library)"
          description="Links the SaveManager to the main Library instance."
          params="library: table"
          returns="void"
        />

        <MethodCard
          name="SaveManager:BuildConfigSection(section)"
          description="Automatically adds input, dropdown, and buttons for config management to a section."
          params="section: Section object"
          returns="void"
        />

        <MethodCard
          name="SaveManager:Save(name)"
          description="Save the current configuration to a file."
          params="name: string"
          returns="void"
        />

        <MethodCard
          name="SaveManager:Load(name)"
          description="Load a configuration from a file."
          params="name: string"
          returns="void"
        />
      </section>

      <InfoBox type="tip">
        <strong>Auto-Load:</strong> The SaveManager automatically handles creating the folder structure 
        and lists available configs in the dropdown.
      </InfoBox>
    </div>
  );
}

import { CodeBlock } from "@/components/CodeBlock";
import { ConfigTable } from "@/components/ConfigTable";
import { PageHeader, MethodCard, InfoBox } from "@/components/DocComponents";

export default function Window() {
  return (
    <div className="max-w-4xl mx-auto px-8 py-12">
      <PageHeader
        title="Window"
        description="The main container for your UI. Every Seisen UI starts with creating a Window."
      />

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Usage</h2>
        <CodeBlock
          code={`local Window = Library:CreateWindow({
    Name = "My Script",
    Icon = "home",
    Theme = Library.Theme,
    ToggleKeybind = Enum.KeyCode.RightShift
})`}
        />
      </section>

      <ConfigTable
        title="Configuration"
        rows={[
          {
            property: "Name",
            type: "string",
            default: '"Seisen UI"',
            description: "The title displayed in the window header",
            required: true,
          },
          {
            property: "Icon",
            type: "string",
            default: '"home"',
            description: "Lucide icon name or Roblox asset ID for the window icon",
          },
          {
            property: "Theme",
            type: "table",
            default: "Library.Theme",
            description: "Theme configuration table (usually use default)",
          },
          {
            property: "ToggleKeybind",
            type: "Enum.KeyCode",
            default: "nil",
            description: "Key to toggle the UI visibility on/off",
          },
        ]}
      />

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Window Methods</h2>
        
        <MethodCard
          name="Window:AddTab(name, subtitle, icon)"
          description="Add a new tab to the window."
          params="name: string, subtitle: string, icon: string"
          returns="Tab object"
        />

        <MethodCard
          name="Window:AddSidebarSection(name)"
          description="Add a section header in the sidebar for organizing tabs."
          params="name: string"
          returns="void"
        />

        <MethodCard
          name="Window:AddSidebarDivider()"
          description="Add a visual divider line in the sidebar."
          returns="void"
        />

        <MethodCard
          name="Window:SetScale(scale)"
          description="Set the UI scale (1.0 = 100%)."
          params="scale: number"
          returns="void"
        />
      </section>

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Full Example</h2>
        <CodeBlock
          code={`local Window = Library:CreateWindow({
    Name = "My Script Hub",
    Icon = "home",
    ToggleKeybind = Enum.KeyCode.RightShift
})

-- Organize sidebar
Window:AddSidebarSection("Main")

-- Add tabs
local HomeTab = Window:AddTab("Home", "Welcome", "home")
local SettingsTab = Window:AddTab("Settings", "Configure", "settings")

Window:AddSidebarDivider()
Window:AddSidebarSection("Modules")

local CombatTab = Window:AddTab("Combat", "Combat features", "sword")
local MovementTab = Window:AddTab("Movement", "Movement mods", "zap")`}
        />
      </section>

      <InfoBox type="tip">
        <strong>Icons:</strong> You can use any Lucide icon name (see lucide.dev/icons) or a Roblox asset ID string.
      </InfoBox>
    </div>
  );
}

import { CodeBlock } from "@/components/CodeBlock";
import { ConfigTable } from "@/components/ConfigTable";
import { PageHeader, MethodCard, InfoBox } from "@/components/DocComponents";

export default function Tabs() {
  return (
    <div className="max-w-4xl mx-auto px-8 py-12">
      <PageHeader
        title="Tabs"
        description="Tabs organize your UI into separate pages. Each tab appears in the sidebar and has its own content area."
      />

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Creating a Tab</h2>
        <CodeBlock
          code={`-- Method 1: Simple syntax
local Tab = Window:AddTab("Home", "Welcome", "home")

-- Method 2: Options table
local Tab = Window:AddTab({
    Name = "Settings",
    Subtitle = "Configure options",
    Icon = "settings"
})`}
        />
      </section>

      <ConfigTable
        title="Configuration"
        rows={[
          {
            property: "Name",
            type: "string",
            default: '"Tab"',
            description: "Display name shown in the sidebar",
            required: true,
          },
          {
            property: "Subtitle",
            type: "string",
            default: "Same as Name",
            description: "Text shown in the breadcrumb when tab is active",
          },
          {
            property: "Icon",
            type: "string",
            default: '"home"',
            description: "Lucide icon name or Roblox asset ID",
          },
        ]}
      />

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Tab Methods</h2>

        <MethodCard
          name="Tab:AddSection(name, side)"
          description="Add a section (groupbox) to the tab."
          params="name: string, side: 'Left' | 'Right'"
          returns="Section object"
        />

        <MethodCard
          name="Tab:AddLeftSection(name)"
          description="Shorthand to add a section to the left column."
          params="name: string"
          returns="Section object"
        />

        <MethodCard
          name="Tab:AddRightSection(name)"
          description="Shorthand to add a section to the right column."
          params="name: string"
          returns="Section object"
        />

        <MethodCard
          name="Tab:AddLeftTabbox(name)"
          description="Add a tabbox to the left column."
          params="name: string"
          returns="Tabbox object"
        />

        <MethodCard
          name="Tab:AddRightTabbox(name)"
          description="Add a tabbox to the right column."
          params="name: string"
          returns="Tabbox object"
        />
      </section>

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Full Example</h2>
        <CodeBlock
          code={`-- Create organized tabs
Window:AddSidebarSection("Main")

local HomeTab = Window:AddTab("Home", "Dashboard", "home")
local PlayerTab = Window:AddTab("Player", "Player mods", "user")

Window:AddSidebarDivider()
Window:AddSidebarSection("Settings")

local ConfigTab = Window:AddTab("Config", "Configuration", "settings")

-- Add sections to a tab
local GeneralSection = HomeTab:AddLeftSection("General")
local StatsSection = HomeTab:AddRightSection("Statistics")

-- Add elements to sections
GeneralSection:AddLabel({ Text = "Welcome to My Script!" })
StatsSection:AddLabel({ Text = "Script loaded successfully" })`}
        />
      </section>

      <InfoBox type="tip">
        <strong>Organization:</strong> Use <code>Window:AddSidebarSection()</code> and 
        <code>Window:AddSidebarDivider()</code> to organize your tabs into logical groups.
      </InfoBox>
    </div>
  );
}

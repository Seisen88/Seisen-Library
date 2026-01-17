import { CodeBlock } from "@/components/CodeBlock";
import { ConfigTable } from "@/components/ConfigTable";
import { PageHeader, MethodCard, InfoBox } from "@/components/DocComponents";

export default function Tabboxes() {
  return (
    <div className="max-w-4xl mx-auto px-8 py-12">
      <PageHeader
        title="Tabboxes"
        description="A container that creates nested tabs within a section, allowing for compact organization."
      />

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Usage</h2>
        <CodeBlock
          code={`-- Add a tabbox to the left side
local TabBox = Tab:AddLeftTabbox()

-- Add tabs to the tabbox
local MainTab = TabBox:AddTab("Main")
local ExtraTab = TabBox:AddTab("Extra")

-- Add elements to these nested tabs
MainTab:AddToggle({ Name = "Enable Main", Flag = "Main" })
ExtraTab:AddToggle({ Name = "Enable Extra", Flag = "Extra" })`}
        />
      </section>

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Methods</h2>
        
        <MethodCard
          name="Tab:AddLeftTabbox(name?)"
          description="Create a new Tabbox in the left column."
          params="name: string (optional)"
          returns="Tabbox object"
        />

        <MethodCard
          name="Tab:AddRightTabbox(name?)"
          description="Create a new Tabbox in the right column."
          params="name: string (optional)"
          returns="Tabbox object"
        />

        <MethodCard
          name="TabBox:AddTab(name)"
          description="Add a new tab to the Tabbox."
          params="name: string"
          returns="Tab object (acts like a Section)"
        />
      </section>

      <InfoBox type="info">
        <strong>Note:</strong> The objects returned by <code>TabBox:AddTab()</code> function exactly like standard Sections. 
        You can add any UI element to them.
      </InfoBox>
    </div>
  );
}

import { CodeBlock } from "@/components/CodeBlock";
import { ConfigTable } from "@/components/ConfigTable";
import { PageHeader, MethodCard, InfoBox } from "@/components/DocComponents";

export default function Sections() {
  return (
    <div className="max-w-4xl mx-auto px-8 py-12">
      <PageHeader
        title="Sections"
        description="Sections (also called Groupboxes) are containers that group related UI elements together."
      />

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Creating a Section</h2>
        <CodeBlock
          code={`-- Add a section to the left column
local LeftSection = Tab:AddSection("General Settings", "Left")

-- Add a section to the right column
local RightSection = Tab:AddSection("Advanced Settings", "Right")

-- Shorthand methods
local LeftSection = Tab:AddLeftSection("General Settings")
local RightSection = Tab:AddRightSection("Advanced Settings")`}
        />
      </section>

      <ConfigTable
        title="Configuration"
        rows={[
          {
            property: "Name",
            type: "string",
            default: '"Section"',
            description: "Title displayed at the top of the section",
            required: true,
          },
          {
            property: "Side",
            type: "string",
            default: '"Left"',
            description: 'Which column to place the section: "Left" or "Right"',
          },
        ]}
      />

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Section Methods</h2>
        <p className="text-[#a0a0a0] mb-4">
          Once you have a Section, you can add any UI element to it:
        </p>

        <MethodCard name="Section:AddLabel(options)" description="Add a text label" />
        <MethodCard name="Section:AddButton(options)" description="Add a clickable button" />
        <MethodCard name="Section:AddToggle(options)" description="Add a toggle switch" />
        <MethodCard name="Section:AddCheckbox(options)" description="Add a checkbox" />
        <MethodCard name="Section:AddSlider(options)" description="Add a slider" />
        <MethodCard name="Section:AddDropdown(options)" description="Add a dropdown menu" />
        <MethodCard name="Section:AddTextbox(options)" description="Add a text input field" />
        <MethodCard name="Section:AddColorPicker(options)" description="Add a color picker" />
        <MethodCard name="Section:AddKeybind(options)" description="Add a keybind input" />
        <MethodCard name="Section:AddDivider(text?)" description="Add a visual divider" />
        <MethodCard name="Section:AddImage(options)" description="Add an image" />
        <MethodCard name="Section:AddViewport(options)" description="Add a 3D viewport" />
        <MethodCard name="Section:AddDependencyBox(options)" description="Add a conditional container" />
        <MethodCard name="Section:AddTabbox(options)" description="Add a nested tabbox" />
      </section>

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Full Example</h2>
        <CodeBlock
          code={`local Settings = Tab:AddLeftSection("Settings")

Settings:AddToggle({
    Name = "Enable Feature",
    Default = false,
    Flag = "FeatureEnabled"
})

Settings:AddDivider("Speed Settings")

Settings:AddSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 100,
    Default = 16,
    Flag = "WalkSpeed"
})

Settings:AddDropdown({
    Name = "Mode",
    Options = {"Normal", "Fast", "Turbo"},
    Default = "Normal",
    Flag = "SpeedMode"
})`}
        />
      </section>

      <InfoBox type="tip">
        <strong>Layout tip:</strong> Use the two-column layout to balance your UI. 
        Put frequently used settings on the left and advanced options on the right.
      </InfoBox>
    </div>
  );
}

import { CodeBlock } from "@/components/CodeBlock";
import { ConfigTable } from "@/components/ConfigTable";
import { PageHeader, MethodCard, InfoBox } from "@/components/DocComponents";

export default function CommonProperties() {
  return (
    <div className="max-w-4xl mx-auto px-8 py-12">
      <PageHeader
        title="Common Properties"
        description="Properties available on all UI elements for consistent behavior and control."
      />

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Overview</h2>
        <p className="text-[#a0a0a0] mb-4">
          Every UI element in Seisen UI supports a set of common properties that provide 
          consistent control over visibility, interactivity, tooltips, and styling.
        </p>
      </section>

      <ConfigTable
        title="Common Properties"
        rows={[
          {
            property: "Name",
            type: "string",
            default: '"Element"',
            description: "Display label for the element",
            required: true,
          },
          {
            property: "Tooltip",
            type: "string",
            default: "nil",
            description: "Description shown when hovering over the element",
          },
          {
            property: "DisabledTooltip",
            type: "string",
            default: "nil",
            description: "Tooltip shown only when the element is disabled",
          },
          {
            property: "Disabled",
            type: "boolean",
            default: "false",
            description: "Makes the element non-interactive (grayed out)",
          },
          {
            property: "Visible",
            type: "boolean",
            default: "true",
            description: "Controls whether the element is shown",
          },
          {
            property: "Risky",
            type: "boolean",
            default: "false",
            description: "Applies red warning styling to indicate danger",
          },
          {
            property: "Flag",
            type: "string",
            default: "nil",
            description: "Unique identifier for saving/referencing the element",
          },
          {
            property: "Callback",
            type: "function",
            default: "nil",
            description: "Function called when the element is interacted with",
          },
        ]}
      />

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Common Methods</h2>
        <p className="text-[#a0a0a0] mb-4">
          All elements with common properties also have these methods:
        </p>
        
        <MethodCard
          name="Element:SetVisible(visible)"
          description="Show or hide the element dynamically."
          params="visible: boolean"
          returns="void"
        />
        
        <MethodCard
          name="Element:SetDisabled(disabled)"
          description="Enable or disable the element. Disabled elements appear grayed out and cannot be interacted with."
          params="disabled: boolean"
          returns="void"
        />
        
        <MethodCard
          name="Element:SetTooltip(text)"
          description="Update the tooltip text shown on hover."
          params="text: string"
          returns="void"
        />
      </section>

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Tooltip Example</h2>
        <CodeBlock
          code={`Section:AddButton({
    Name = "Teleport",
    Tooltip = "Teleport to the nearest enemy",
    DisabledTooltip = "No enemies nearby",
    Callback = function()
        teleportToEnemy()
    end
})

-- Disable later when no enemies
button:SetDisabled(true)`}
        />
      </section>

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Risky Styling</h2>
        <p className="text-[#a0a0a0] mb-4">
          Use the <code>Risky</code> property to visually warn users about dangerous actions:
        </p>
        <CodeBlock
          code={`Section:AddButton({
    Name = "Delete All Data",
    Risky = true,
    ConfirmText = "Click again to confirm",
    Tooltip = "This action cannot be undone!",
    Callback = function()
        -- Delete data
    end
})`}
        />
      </section>

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Conditional Visibility</h2>
        <p className="text-[#a0a0a0] mb-4">
          Use <code>Visible</code> and <code>SetVisible()</code> to create conditional UI:
        </p>
        <CodeBlock
          code={`-- Create a toggle that controls other elements' visibility
Section:AddToggle({
    Name = "Advanced Mode",
    Flag = "AdvancedMode",
    Callback = function(enabled)
        Library.Options.AdvancedSlider:SetVisible(enabled)
        Library.Options.AdvancedDropdown:SetVisible(enabled)
    end
})

-- Hidden by default, shown when Advanced Mode is enabled
Section:AddSlider({
    Name = "Custom Value",
    Flag = "AdvancedSlider",
    Visible = false,
    Min = 0,
    Max = 100
})

Section:AddDropdown({
    Name = "Custom Option",
    Flag = "AdvancedDropdown", 
    Visible = false,
    Options = {"A", "B", "C"}
})`}
        />
      </section>

      <InfoBox type="tip">
        <strong>Best Practice:</strong> Use tooltips to provide context and help text, 
        especially for complex or non-obvious features.
      </InfoBox>
    </div>
  );
}

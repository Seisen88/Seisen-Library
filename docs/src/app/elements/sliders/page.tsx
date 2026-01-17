import { CodeBlock } from "@/components/CodeBlock";
import { ConfigTable } from "@/components/ConfigTable";
import { PageHeader, MethodCard, InfoBox } from "@/components/DocComponents";

export default function Sliders() {
  return (
    <div className="max-w-4xl mx-auto px-8 py-12">
      <PageHeader
        title="Sliders"
        description="A numeric input with a draggable slider for selecting values within a range."
      />

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Usage</h2>
        <CodeBlock
          code={`Section:AddSlider({
    Name = "Walk Speed",
    Min = 0,
    Max = 100,
    Default = 16,
    Flag = "WalkSpeed",
    Callback = function(Value)
        LocalPlayer.Character.Humanoid.WalkSpeed = Value
    end
})`}
        />
      </section>

      <ConfigTable
        title="Configuration"
        rows={[
          {
            property: "Name",
            type: "string",
            default: '"Slider"',
            description: "Display name shown above the slider",
            required: true,
          },
          {
            property: "Min",
            type: "number",
            default: "0",
            description: "Minimum value of the slider",
            required: true,
          },
          {
            property: "Max",
            type: "number",
            default: "100",
            description: "Maximum value of the slider",
            required: true,
          },
          {
            property: "Default",
            type: "number",
            default: "Min value",
            description: "Initial value of the slider",
          },
          {
            property: "Increment",
            type: "number",
            default: "1",
            description: "Step size for value changes (e.g., 0.1 for decimals, 5 for multiples of 5)",
          },
          {
            property: "Suffix",
            type: "string",
            default: '""',
            description: 'Text displayed after the value (e.g., "%", "px", " studs")',
          },
          {
            property: "Prefix",
            type: "string",
            default: '""',
            description: 'Text displayed before the value (e.g., "$", "+")',
          },
          {
            property: "HideMax",
            type: "boolean",
            default: "false",
            description: "Hide the maximum value label",
          },
          {
            property: "Flag",
            type: "string",
            default: "nil",
            description: "Unique identifier for saving/referencing via Library.Options",
          },
          {
            property: "Callback",
            type: "function",
            default: "nil",
            description: "Function called when value changes. Receives the new number value.",
          },
          {
            property: "Tooltip",
            type: "string",
            default: "nil",
            description: "Hover description text",
          },
          {
            property: "Disabled",
            type: "boolean",
            default: "false",
            description: "Makes the slider non-interactive",
          },
          {
            property: "Visible",
            type: "boolean",
            default: "true",
            description: "Controls slider visibility",
          },
        ]}
      />

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Methods</h2>
        <MethodCard
          name="Slider:SetValue(value)"
          description="Programmatically set the slider value."
          params="value: number"
          returns="void"
        />
        <MethodCard
          name="Slider:SetVisible(visible)"
          description="Show or hide the slider."
          params="visible: boolean"
          returns="void"
        />
        <MethodCard
          name="Slider:SetDisabled(disabled)"
          description="Enable or disable the slider."
          params="disabled: boolean"
          returns="void"
        />
      </section>

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Suffix/Prefix Example</h2>
        <CodeBlock
          code={`-- Percentage slider
Section:AddSlider({
    Name = "Opacity",
    Min = 0,
    Max = 100,
    Default = 100,
    Suffix = "%",
    Flag = "Opacity"
})

-- Price slider
Section:AddSlider({
    Name = "Price",
    Min = 0,
    Max = 1000,
    Default = 100,
    Prefix = "$",
    Increment = 10,
    Flag = "Price"
})

-- Decimal slider
Section:AddSlider({
    Name = "Scale",
    Min = 0.5,
    Max = 2.0,
    Default = 1.0,
    Increment = 0.1,
    Suffix = "x",
    Flag = "Scale"
})`}
        />
      </section>

      <InfoBox type="info">
        <strong>Increment:</strong> Use <code>Increment</code> to control the step size. 
        For example, <code>Increment = 0.1</code> allows decimal values like 1.1, 1.2, etc.
      </InfoBox>
    </div>
  );
}

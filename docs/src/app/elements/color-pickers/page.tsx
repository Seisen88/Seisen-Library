import { CodeBlock } from "@/components/CodeBlock";
import { ConfigTable } from "@/components/ConfigTable";
import { PageHeader, MethodCard } from "@/components/DocComponents";

export default function ColorPickers() {
  return (
    <div className="max-w-4xl mx-auto px-8 py-12">
      <PageHeader
        title="Color Pickers"
        description="An interactive color selection tool with preset colors and custom input."
      />

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Usage</h2>
        <CodeBlock
          code={`Section:AddColorPicker({
    Name = "Highlight Color",
    Default = Color3.fromRGB(0, 200, 100),
    Flag = "HighlightColor",
    Callback = function(Color)
        print("Color selected:", Color)
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
            default: '"Color"',
            description: "Display name shown next to the color picker",
            required: true,
          },
          {
            property: "Default",
            type: "Color3",
            default: "Color3.new(1,1,1)",
            description: "Initial color value",
          },
          {
            property: "Flag",
            type: "string",
            default: "nil",
            description: "Unique identifier for saving/referencing",
          },
          {
            property: "Callback",
            type: "function",
            default: "nil",
            description: "Function called when color changes. Receives Color3 value.",
          },
        ]}
      />

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Methods</h2>
        <MethodCard
          name="ColorPicker:SetValue(color)"
          description="Programmatically set the color."
          params="color: Color3"
          returns="void"
        />
      </section>

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Example: ESP Color</h2>
        <CodeBlock
          code={`Section:AddColorPicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(255, 0, 0),
    Flag = "ESPColor",
    Callback = function(Color)
        -- Update all ESP highlights
        for _, highlight in pairs(ESPHighlights) do
            highlight.FillColor = Color
            highlight.OutlineColor = Color
        end
    end
})`}
        />
      </section>
    </div>
  );
}

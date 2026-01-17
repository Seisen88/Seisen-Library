import { CodeBlock } from "@/components/CodeBlock";
import { ConfigTable } from "@/components/ConfigTable";
import { PageHeader, MethodCard } from "@/components/DocComponents";

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
      </section>

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Features</h2>
        <ul className="list-disc list-inside text-[#a0a0a0] space-y-2">
          <li><strong className="text-white">Click to Jump:</strong> Click anywhere on the slider bar to jump to that value</li>
          <li><strong className="text-white">Smooth Dragging:</strong> Drag the knob for precise value selection</li>
          <li><strong className="text-white">Real-time Updates:</strong> Value updates in real-time as you drag</li>
          <li><strong className="text-white">UIScale Compatible:</strong> Works correctly even when UI is scaled</li>
        </ul>
      </section>

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Accessing Slider Value</h2>
        <CodeBlock
          code={`-- Get current value
local speed = Library.Options.WalkSpeed.Value

-- Set value programmatically
Library.Options.WalkSpeed:SetValue(50)`}
        />
      </section>
    </div>
  );
}

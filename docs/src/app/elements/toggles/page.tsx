import { CodeBlock } from "@/components/CodeBlock";
import { ConfigTable } from "@/components/ConfigTable";
import { PageHeader, MethodCard, InfoBox } from "@/components/DocComponents";

export default function Toggles() {
  return (
    <div className="max-w-4xl mx-auto px-8 py-12">
      <PageHeader
        title="Toggles"
        description="A boolean switch that can be toggled on/off. Supports optional keybind."
      />

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Usage</h2>
        <CodeBlock
          code={`Section:AddToggle({
    Name = "Enable Feature",
    Default = false,
    Flag = "FeatureToggle",
    Callback = function(Value)
        print("Toggle value:", Value)
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
            default: '"Toggle"',
            description: "Display name shown next to the toggle",
            required: true,
          },
          {
            property: "Default",
            type: "boolean",
            default: "false",
            description: "Initial state of the toggle",
          },
          {
            property: "Flag",
            type: "string",
            default: "nil",
            description: "Unique identifier for saving/referencing via Library.Toggles",
          },
          {
            property: "Callback",
            type: "function",
            default: "nil",
            description: "Function called when toggle state changes. Receives boolean value.",
          },
          {
            property: "Keybind",
            type: "Enum.KeyCode",
            default: "nil",
            description: "Optional keybind to toggle this setting",
          },
        ]}
      />

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Methods</h2>
        <MethodCard
          name="Toggle:SetValue(value)"
          description="Programmatically set the toggle state."
          params="value: boolean"
          returns="void"
        />
      </section>

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Toggle with Keybind</h2>
        <p className="text-[#a0a0a0] mb-4">
          You can attach a keybind to a toggle so users can press a key to toggle it:
        </p>
        <CodeBlock
          code={`Section:AddToggle({
    Name = "Sprint",
    Default = false,
    Flag = "SprintToggle",
    Keybind = Enum.KeyCode.LeftShift,
    Callback = function(Value)
        -- Enable/disable sprinting
        LocalPlayer.Character.Humanoid.WalkSpeed = Value and 32 or 16
    end
})`}
        />
      </section>

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Accessing Toggle State</h2>
        <p className="text-[#a0a0a0] mb-4">
          You can access the current toggle state using the Flag:
        </p>
        <CodeBlock
          code={`-- Check if toggle is enabled
if Library.Toggles.FeatureToggle.Value then
    -- Do something
end

-- Set toggle programmatically
Library.Toggles.FeatureToggle:SetValue(true)`}
        />
      </section>

      <InfoBox type="info">
        <strong>Note:</strong> The Callback function is also called when using SetValue(), 
        so you don&apos;t need to manually trigger your logic.
      </InfoBox>
    </div>
  );
}

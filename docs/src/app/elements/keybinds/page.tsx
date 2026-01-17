import { CodeBlock } from "@/components/CodeBlock";
import { ConfigTable } from "@/components/ConfigTable";
import { PageHeader, MethodCard, InfoBox } from "@/components/DocComponents";

export default function Keybinds() {
  return (
    <div className="max-w-4xl mx-auto px-8 py-12">
      <PageHeader
        title="Keybinds"
        description="An input for capturing keyboard shortcuts that trigger actions."
      />

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Usage</h2>
        <CodeBlock
          code={`Section:AddKeybind({
    Name = "Activate",
    Default = "E",
    Mode = "Toggle",
    Flag = "ActivateKey",
    Callback = function()
        print("Keybind pressed!")
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
            default: '"Keybind"',
            description: "Display name shown next to the keybind",
            required: true,
          },
          {
            property: "Default",
            type: "string",
            default: '""',
            description: "Initial key (e.g., 'E', 'F', 'LeftShift')",
          },
          {
            property: "Mode",
            type: "string",
            default: '"Toggle"',
            description: "How the keybind works: 'Toggle', 'Hold', or 'Always'",
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
            description: "Function called when the keybind is activated",
          },
        ]}
      />

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Keybind Modes</h2>
        <ul className="space-y-3 text-[#a0a0a0]">
          <li>
            <strong className="text-white">Toggle:</strong> Press once to enable, press again to disable
          </li>
          <li>
            <strong className="text-white">Hold:</strong> Active only while the key is held down
          </li>
          <li>
            <strong className="text-white">Always:</strong> Triggers every time the key is pressed
          </li>
        </ul>
      </section>

      <InfoBox type="info">
        <strong>Rebinding:</strong> Users can click on the keybind button and press a new key to change it.
      </InfoBox>
    </div>
  );
}

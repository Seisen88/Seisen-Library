import { CodeBlock } from "@/components/CodeBlock";
import { ConfigTable } from "@/components/ConfigTable";
import { PageHeader, InfoBox } from "@/components/DocComponents";

export default function Buttons() {
  return (
    <div className="max-w-4xl mx-auto px-8 py-12">
      <PageHeader
        title="Buttons"
        description="A clickable button that triggers an action when pressed."
      />

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Usage</h2>
        <CodeBlock
          code={`Section:AddButton({
    Name = "Click Me",
    Callback = function()
        print("Button was clicked!")
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
            default: '"Button"',
            description: "Text displayed on the button",
            required: true,
          },
          {
            property: "Callback",
            type: "function",
            default: "nil",
            description: "Function called when the button is clicked",
            required: true,
          },
          {
            property: "DoubleClick",
            type: "boolean",
            default: "false",
            description: "Require double-click to activate",
          },
          {
            property: "ConfirmText",
            type: "string",
            default: "nil",
            description: "Text shown on first click, requires second click to confirm",
          },
          {
            property: "Tooltip",
            type: "string",
            default: "nil",
            description: "Hover description text",
          },
          {
            property: "DisabledTooltip",
            type: "string",
            default: "nil",
            description: "Tooltip shown when button is disabled",
          },
          {
            property: "Disabled",
            type: "boolean",
            default: "false",
            description: "Makes the button non-interactive",
          },
          {
            property: "Visible",
            type: "boolean",
            default: "true",
            description: "Controls button visibility",
          },
          {
            property: "Risky",
            type: "boolean",
            default: "false",
            description: "Applies red warning styling to the button",
          },
          {
            property: "Flag",
            type: "string",
            default: "nil",
            description: "Unique identifier for referencing via Library.Options",
          },
        ]}
      />

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Risky Button Example</h2>
        <p className="text-[#a0a0a0] mb-4">
          Use the Risky option for dangerous actions like reset or delete:
        </p>
        <CodeBlock
          code={`Section:AddButton({
    Name = "Reset All Settings",
    Risky = true,
    ConfirmText = "Click again to confirm",
    Callback = function()
        -- Reset all settings
        for _, toggle in pairs(Library.Toggles) do
            toggle:SetValue(false)
        end
    end
})`}
        />
      </section>

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Double Click Example</h2>
        <CodeBlock
          code={`Section:AddButton({
    Name = "Teleport to Spawn",
    DoubleClick = true,
    Tooltip = "Double-click to teleport",
    Callback = function()
        local spawnPoint = workspace:FindFirstChild("SpawnLocation")
        if spawnPoint and LocalPlayer.Character then
            LocalPlayer.Character:PivotTo(spawnPoint.CFrame + Vector3.new(0, 5, 0))
        end
    end
})`}
        />
      </section>

      <InfoBox type="tip">
        <strong>Confirmation:</strong> Use <code>ConfirmText</code> together with <code>Risky</code> 
        for destructive actions that require explicit user confirmation.
      </InfoBox>
    </div>
  );
}

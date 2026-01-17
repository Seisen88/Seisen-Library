import { CodeBlock } from "@/components/CodeBlock";
import { ConfigTable } from "@/components/ConfigTable";
import { PageHeader, MethodCard } from "@/components/DocComponents";

export default function Dropdowns() {
  return (
    <div className="max-w-4xl mx-auto px-8 py-12">
      <PageHeader
        title="Dropdowns"
        description="A selection menu that allows users to choose from a list of options."
      />

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Usage</h2>
        <CodeBlock
          code={`Section:AddDropdown({
    Name = "Select Mode",
    Options = {"Option A", "Option B", "Option C"},
    Default = "Option A",
    Flag = "ModeSelection",
    Callback = function(Value)
        print("Selected:", Value)
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
            default: '"Dropdown"',
            description: "Display name shown above the dropdown",
            required: true,
          },
          {
            property: "Options",
            type: "table",
            default: "{}",
            description: "Array of options to display in the dropdown",
            required: true,
          },
          {
            property: "Default",
            type: "string",
            default: "First option",
            description: "Initially selected option",
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
            description: "Function called when selection changes. Receives selected value.",
          },
        ]}
      />

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Methods</h2>
        <MethodCard
          name="Dropdown:SetValue(value)"
          description="Programmatically set the selected option."
          params="value: string (must match an option)"
          returns="void"
        />
      </section>

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Dynamic Options Example</h2>
        <CodeBlock
          code={`-- Get players for dropdown
local function getPlayers()
    local players = {}
    for _, player in ipairs(game.Players:GetPlayers()) do
        table.insert(players, player.Name)
    end
    return players
end

Section:AddDropdown({
    Name = "Target Player",
    Options = getPlayers(),
    Default = "Select...",
    Flag = "TargetPlayer",
    Callback = function(playerName)
        local target = game.Players:FindFirstChild(playerName)
        if target then
            print("Target set to:", target)
        end
    end
})`}
        />
      </section>
    </div>
  );
}

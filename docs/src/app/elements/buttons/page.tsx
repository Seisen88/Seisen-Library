import { CodeBlock } from "@/components/CodeBlock";
import { ConfigTable } from "@/components/ConfigTable";
import { PageHeader, MethodCard } from "@/components/DocComponents";

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
        ]}
      />

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Example: Teleport Button</h2>
        <CodeBlock
          code={`Section:AddButton({
    Name = "Teleport to Spawn",
    Callback = function()
        local spawnPoint = workspace:FindFirstChild("SpawnLocation")
        if spawnPoint and LocalPlayer.Character then
            LocalPlayer.Character:PivotTo(spawnPoint.CFrame + Vector3.new(0, 5, 0))
        end
    end
})`}
        />
      </section>
    </div>
  );
}

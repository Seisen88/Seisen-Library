import { CodeBlock } from "@/components/CodeBlock";
import { ConfigTable } from "@/components/ConfigTable";
import { PageHeader } from "@/components/DocComponents";

export default function Checkboxes() {
  return (
    <div className="max-w-4xl mx-auto px-8 py-12">
      <PageHeader
        title="Checkboxes"
        description="A checkbox-style boolean input, similar to Toggle but with a different visual style."
      />

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Usage</h2>
        <CodeBlock
          code={`Section:AddCheckbox({
    Name = "Show Notifications",
    Default = true,
    Flag = "ShowNotifs",
    Callback = function(Value)
        print("Checkbox:", Value)
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
            default: '"Checkbox"',
            description: "Display name shown next to the checkbox",
            required: true,
          },
          {
            property: "Default",
            type: "boolean",
            default: "false",
            description: "Initial checked state",
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
            description: "Function called when state changes. Receives boolean value.",
          },
        ]}
      />
    </div>
  );
}

import { CodeBlock } from "@/components/CodeBlock";
import { ConfigTable } from "@/components/ConfigTable";
import { PageHeader } from "@/components/DocComponents";

export default function Labels() {
  return (
    <div className="max-w-4xl mx-auto px-8 py-12">
      <PageHeader
        title="Labels"
        description="Static text elements for displaying information or instructions."
      />

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Usage</h2>
        <CodeBlock
          code={`Section:AddLabel({ Text = "This is a label" })`}
        />
      </section>

      <ConfigTable
        title="Configuration"
        rows={[
          {
            property: "Text",
            type: "string",
            default: '""',
            description: "The text content to display",
            required: true,
          },
        ]}
      />

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Examples</h2>
        <CodeBlock
          code={`-- Information label
Section:AddLabel({ Text = "Welcome to My Script!" })

-- Instruction label
Section:AddLabel({ Text = "Press RightShift to toggle UI" })

-- Status label
Section:AddLabel({ Text = "Script Version: 1.0.0" })`}
        />
      </section>
    </div>
  );
}

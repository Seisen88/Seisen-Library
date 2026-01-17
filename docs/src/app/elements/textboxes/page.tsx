import { CodeBlock } from "@/components/CodeBlock";
import { ConfigTable } from "@/components/ConfigTable";
import { PageHeader, MethodCard } from "@/components/DocComponents";

export default function Textboxes() {
  return (
    <div className="max-w-4xl mx-auto px-8 py-12">
      <PageHeader
        title="Textboxes"
        description="A text input field for user-entered strings."
      />

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Usage</h2>
        <CodeBlock
          code={`Section:AddTextbox({
    Name = "Player Name",
    Default = "",
    Placeholder = "Enter name...",
    Flag = "TargetName",
    Callback = function(Text)
        print("Input:", Text)
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
            default: '"Input"',
            description: "Display name shown above the textbox",
            required: true,
          },
          {
            property: "Default",
            type: "string",
            default: '""',
            description: "Initial text value",
          },
          {
            property: "Placeholder",
            type: "string",
            default: '""',
            description: "Placeholder text shown when empty",
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
            description: "Function called when focus is lost. Receives text string.",
          },
        ]}
      />

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Methods</h2>
        <MethodCard
          name="Textbox:SetValue(text)"
          description="Programmatically set the text content."
          params="text: string"
          returns="void"
        />
      </section>
    </div>
  );
}

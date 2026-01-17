import { CodeBlock } from "@/components/CodeBlock";
import { ConfigTable } from "@/components/ConfigTable";
import { PageHeader, InfoBox } from "@/components/DocComponents";

export default function Passthrough() {
  return (
    <div className="max-w-4xl mx-auto px-8 py-12">
      <PageHeader
        title="Passthrough"
        description="Documentation about passthrough behavior and styling customization."
      />

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Concept</h2>
        <p className="text-[#a0a0a0] mb-4">
          Passthrough allows you to seamlessly integrate custom UI elements into the library layout.
          However, Seisen UI generally encourages using standard elements or creating new Library extensions.
        </p>
        <p className="text-[#a0a0a0] mb-4">
          If you need to insert a custom Roblox Instance into a Section:
        </p>
      </section>

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Manually Inserting Elements</h2>
        <CodeBlock
          code={`local MyFrame = Instance.new("Frame")
MyFrame.Size = UDim2.new(1, 0, 0, 50)
MyFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)

-- Parent directly to the section's content container
MyFrame.Parent = Section.Container`}
        />
      </section>

      <InfoBox type="warning">
        <strong>Compatibility:</strong> Manually inserting elements may break automatic resizing or theming. 
        Ensure you handle layout updates appropriately.
      </InfoBox>
    </div>
  );
}

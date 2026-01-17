import { CodeBlock } from "@/components/CodeBlock";
import { ConfigTable } from "@/components/ConfigTable";
import { PageHeader } from "@/components/DocComponents";

export default function Dividers() {
  return (
    <div className="max-w-4xl mx-auto px-8 py-12">
      <PageHeader
        title="Dividers"
        description="Visual separators to organize elements within a section."
      />

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Usage</h2>
        <CodeBlock
          code={`-- Simple divider line
Section:AddDivider()

-- Divider with text label
Section:AddDivider("Settings")`}
        />
      </section>

      <ConfigTable
        title="Arguments"
        rows={[
          {
            property: "text",
            type: "string",
            default: "nil",
            description: "Optional text label displayed on the divider",
          },
        ]}
      />

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Example</h2>
        <CodeBlock
          code={`Section:AddToggle({ Name = "Enable ESP", Flag = "ESP" })
Section:AddToggle({ Name = "Show Names", Flag = "ESPNames" })

Section:AddDivider("Advanced")

Section:AddSlider({ Name = "Draw Distance", Min = 100, Max = 1000, Flag = "ESPDist" })
Section:AddColorPicker({ Name = "ESP Color", Flag = "ESPColor" })`}
        />
      </section>
    </div>
  );
}

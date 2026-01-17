import { CodeBlock } from "@/components/CodeBlock";
import { ConfigTable } from "@/components/ConfigTable";
import { PageHeader, MethodCard } from "@/components/DocComponents";

export default function Images() {
  return (
    <div className="max-w-4xl mx-auto px-8 py-12">
      <PageHeader
        title="Images"
        description="Display internal or external images within your UI."
      />

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Usage</h2>
        <CodeBlock
          code={`Section:AddImage({
    Name = "My Image",
    Image = "rbxassetid://1234567890",
    Size = UDim2.new(0, 100, 0, 100)
})`}
        />
      </section>

      <ConfigTable
        title="Configuration"
        rows={[
          {
            property: "Name",
            type: "string",
            default: '"Image"',
            description: "Optional display name",
          },
          {
            property: "Image",
            type: "string",
            default: '""',
            description: "Roblox asset ID or image URL",
            required: true,
          },
          {
            property: "Size",
            type: "UDim2",
            default: "UDim2.new(0, 100, 0, 100)",
            description: "Size of the image",
          },
          {
            property: "Tooltip",
            type: "string",
            default: "nil",
            description: "Hover text",
          },
          {
            property: "Visible",
            type: "boolean",
            default: "true",
            description: "Controls visibility",
          },
        ]}
      />

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Methods</h2>
        
        <MethodCard
          name="Image:SetImage(imageId)"
          description="Update the displayed image."
          params="imageId: string"
          returns="void"
        />

        <MethodCard
          name="Image:SetVisible(visible)"
          description="Show or hide the image."
          params="visible: boolean"
          returns="void"
        />
      </section>
    </div>
  );
}

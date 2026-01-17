import { CodeBlock } from "@/components/CodeBlock";
import { ConfigTable } from "@/components/ConfigTable";
import { PageHeader, MethodCard } from "@/components/DocComponents";

export default function Viewports() {
  return (
    <div className="max-w-4xl mx-auto px-8 py-12">
      <PageHeader
        title="Viewports"
        description="Display 3D models or character previews within your UI."
      />

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Usage</h2>
        <CodeBlock
          code={`Section:AddViewport({
    Name = "Character Preview",
    Model = LocalPlayer.Character,
    Size = UDim2.new(1, 0, 0, 200),
    CameraDistance = 5
})`}
        />
      </section>

      <ConfigTable
        title="Configuration"
        rows={[
          {
            property: "Name",
            type: "string",
            default: '"Viewport"',
            description: "Optional display name",
          },
          {
            property: "Model",
            type: "Instance",
            default: "nil",
            description: "The 3D model/Part/Character to display",
            required: true,
          },
          {
            property: "Size",
            type: "UDim2",
            default: "UDim2.new(1, 0, 0, 200)",
            description: "Size of the viewport frame",
          },
          {
            property: "CameraDistance",
            type: "number",
            default: "5",
            description: "Distance of the camera from the model",
          },
          {
            property: "LightDirection",
            type: "Vector3",
            default: "Vector3.new(-1, -1, -1)",
            description: "Direction of the light source",
          },
          {
             property: "CameraCFrame",
             type: "CFrame",
             default: "nil",
             description: "Manually set camera position (overrides distance)"
          }
        ]}
      />

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Methods</h2>
        
        <MethodCard
          name="Viewport:SetModel(model)"
          description="Update the displayed model."
          params="model: Instance"
          returns="void"
        />

        <MethodCard
          name="Viewport:UpdateCamera()"
          description="Force update the camera position."
          returns="void"
        />
      </section>
    </div>
  );
}

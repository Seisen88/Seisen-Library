import { CodeBlock } from "@/components/CodeBlock";
import { ConfigTable } from "@/components/ConfigTable";
import { PageHeader, MethodCard } from "@/components/DocComponents";

export default function DependencyBox() {
  return (
    <div className="max-w-4xl mx-auto px-8 py-12">
      <PageHeader
        title="DependencyBox"
        description="A container that automatically shows or hides based on the state of a toggle or dropdown."
      />

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Usage</h2>
        <CodeBlock
          code={`local Toggle = Section:AddToggle({ Name = "Enable Aimbot", Flag = "Aimbot" })

local Box = Section:AddDependencyBox()
Box:AddSlider({ Name = "FOV", Min = 0, Max = 180, Default = 90 })
Box:AddToggle({ Name = "Show FOV Circle" })

-- Link the box to the toggle
Box:SetupDependencies({
    { Toggle, true } -- Show when Toggle is true
})`}
        />
      </section>

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Configuration</h2>
        <ConfigTable
          rows={[
            {
              property: "Name",
              type: "string",
              default: "nil",
              description: "Optional name for the container",
            },
          ]}
        />
      </section>

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Methods</h2>
        
        <MethodCard
          name="DependencyBox:SetupDependencies(dependencies)"
          description="Links specific elements to control the box's visibility."
          params="dependencies: table {{Element, ExpectedValue}, ...}"
          returns="void"
        />
      </section>

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Complex Example</h2>
        <CodeBlock
          code={`local AimbotToggle = Section:AddToggle({ Name = "Aimbot" })
local TypeDropdown = Section:AddDropdown({ Name = "Type", Options = {"Silent", "Mouse"} })

local SilentSettings = Section:AddDependencyBox()
SilentSettings:AddSlider({ Name = "Silent FOV" })

-- Show only when Aimbot is ON and Type is "Silent"
SilentSettings:SetupDependencies({
    { AimbotToggle, true },
    { TypeDropdown, "Silent" }
})`}
        />
      </section>
    </div>
  );
}

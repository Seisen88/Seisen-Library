import { CodeBlock } from "@/components/CodeBlock";
import { PageHeader, InfoBox } from "@/components/DocComponents";

export default function Structuring() {
  return (
    <div className="max-w-4xl mx-auto px-8 py-12">
      <PageHeader
        title="Structuring"
        description="Understanding the hierarchy and structure of Seisen UI components."
      />

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Component Hierarchy</h2>
        <p className="text-[#a0a0a0] mb-4">
          Seisen UI follows a strict parent-child hierarchy. Understanding this structure 
          is essential for building your interface correctly.
        </p>
        
        <div className="bg-[#111111] border border-[#2d2d32] rounded-lg p-6 my-6 font-mono text-sm">
          <div className="text-[#00c864]">Library</div>
          <div className="ml-4 text-[#a0a0a0]">└── <span className="text-[#ff79c6]">Window</span></div>
          <div className="ml-8 text-[#a0a0a0]">├── <span className="text-[#8be9fd]">Sidebar Sections</span></div>
          <div className="ml-8 text-[#a0a0a0]">├── <span className="text-[#8be9fd]">Sidebar Dividers</span></div>
          <div className="ml-8 text-[#a0a0a0]">└── <span className="text-[#f1fa8c]">Tabs</span></div>
          <div className="ml-12 text-[#a0a0a0]">├── <span className="text-[#bd93f9]">Sections (Left/Right)</span></div>
          <div className="ml-16 text-[#a0a0a0]">└── <span className="text-white">UI Elements</span></div>
          <div className="ml-12 text-[#a0a0a0]">└── <span className="text-[#bd93f9]">Tabboxes</span></div>
          <div className="ml-16 text-[#a0a0a0]">└── <span className="text-white">Inner Tabs → Elements</span></div>
        </div>
      </section>

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Basic Structure Example</h2>
        <CodeBlock
          code={`-- 1. Create Window (root container)
local Window = Library:CreateWindow({
    Name = "My Script"
})

-- 2. Add sidebar organization (optional)
Window:AddSidebarSection("Main")

-- 3. Add Tabs (pages in your UI)
local Tab = Window:AddTab("Settings", "Configure options", "settings")

-- 4. Add Sections to Tabs (columns)
local LeftSection = Tab:AddSection("General", "Left")
local RightSection = Tab:AddSection("Advanced", "Right")

-- 5. Add Elements to Sections
LeftSection:AddToggle({
    Name = "Enable Feature",
    Default = false
})

RightSection:AddSlider({
    Name = "Speed",
    Min = 0,
    Max = 100,
    Default = 50
})`}
        />
      </section>

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Two-Column Layout</h2>
        <p className="text-[#a0a0a0] mb-4">
          Each Tab has a two-column layout. You can add Sections to either the left or right column:
        </p>
        <CodeBlock
          code={`-- Using AddSection with side parameter
local Left = Tab:AddSection("Left Content", "Left")
local Right = Tab:AddSection("Right Content", "Right")

-- Or using explicit methods
local Left = Tab:AddLeftSection("Left Content")
local Right = Tab:AddRightSection("Right Content")`}
        />
      </section>

      <InfoBox type="tip">
        <strong>Best Practice:</strong> Group related settings together in the same section, 
        and use the two-column layout to organize different setting categories.
      </InfoBox>
    </div>
  );
}

import { CodeBlock } from "@/components/CodeBlock";
import { ConfigTable } from "@/components/ConfigTable";
import { PageHeader, MethodCard } from "@/components/DocComponents";

export default function ThemeManager() {
  return (
    <div className="max-w-4xl mx-auto px-8 py-12">
      <PageHeader
        title="ThemeManager"
        description="System for managing and applying visual themes to the UI."
      />

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Setup</h2>
        <CodeBlock
          code={`local ThemeManager = Library.ThemeManager
ThemeManager:SetLibrary(Library)

-- Add the ThemeManager UI to a section
local ThemeSection = SettingsTab:AddLeftSection("Theme")
ThemeManager:ApplyToSection(ThemeSection)`}
        />
      </section>

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Default Themes</h2>
        <ul className="list-disc list-inside text-[#a0a0a0] space-y-2 mb-6">
          <li>Defualt (Dark)</li>
          <li>BBot</li>
          <li>Fatality</li>
          <li>Inis</li>
          <li>Jester</li>
          <li>Mint</li>
          <li>Tokyo Night</li>
        </ul>
      </section>

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Methods</h2>
        
        <MethodCard
          name="ThemeManager:ApplyToSection(section)"
          description="Adds a dropdown to select themes and color pickers to customize specific UI elements."
          params="section: Section object"
          returns="void"
        />

        <MethodCard
          name="ThemeManager:ApplyTheme(themeName)"
          description="Programmatically apply a theme."
          params="themeName: string"
          returns="void"
        />
      </section>

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Custom Themes</h2>
        <p className="text-[#a0a0a0] mb-4">
          You can define custom themes by modifying the <code>Library.Theme</code> table directly or 
          creating a JSON themes file if using the SaveManager.
        </p>
      </section>
    </div>
  );
}

import { CodeBlock } from "@/components/CodeBlock";
import { ConfigTable } from "@/components/ConfigTable";
import { PageHeader, MethodCard, InfoBox } from "@/components/DocComponents";

export default function Library() {
  return (
    <div className="max-w-4xl mx-auto px-8 py-12">
      <PageHeader
        title="Library"
        description="Core library methods available globally after loading Seisen UI."
      />

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Loading the Library</h2>
        <CodeBlock
          code={`local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ken-884/Seisen-Library/main/SeisenUI.lua"))()`}
        />
      </section>

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Library Methods</h2>

        <MethodCard
          name="Library:CreateWindow(options)"
          description="Create the main UI window. This is the first thing you call after loading the library."
          params="options: table (see Window documentation)"
          returns="Window object"
        />

        <MethodCard
          name="Library:Toggle()"
          description="Toggle the UI visibility on/off. Called automatically by the toggle keybind if set."
          returns="void"
        />

        <MethodCard
          name="Library:Unload()"
          description="Completely destroy and clean up the UI. Use this when unloading your script."
          returns="void"
        />

        <MethodCard
          name="Library:ApplyTheme(themeName)"
          description="Apply a built-in theme by name."
          params="themeName: string"
          returns="void"
        />
      </section>

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Library Properties</h2>
        <ConfigTable
          rows={[
            {
              property: "Library.ScreenGui",
              type: "ScreenGui",
              default: "-",
              description: "Reference to the main ScreenGui instance",
            },
            {
              property: "Library.Theme",
              type: "table",
              default: "Default theme",
              description: "Current theme color configuration",
            },
            {
              property: "Library.Options",
              type: "table",
              default: "{}",
              description: "All UI elements with Flag property (sliders, dropdowns, etc.)",
            },
            {
              property: "Library.Toggles",
              type: "table",
              default: "{}",
              description: "All toggle elements with Flag property",
            },
            {
              property: "Library.ToggleKeybind",
              type: "Enum.KeyCode",
              default: "nil",
              description: "Key used to toggle UI visibility",
            },
          ]}
        />
      </section>

      <section className="mb-12">
        <h2 className="text-2xl font-semibold text-white mb-4">Accessing Elements</h2>
        <CodeBlock
          code={`-- Access a toggle by its Flag
local isEnabled = Library.Toggles.MyToggle.Value
Library.Toggles.MyToggle:SetValue(true)

-- Access a slider/dropdown by its Flag
local speed = Library.Options.WalkSpeed.Value
Library.Options.WalkSpeed:SetValue(25)`}
        />
      </section>

      <InfoBox type="warning">
        <strong>Important:</strong> Always use <code>Library:Unload()</code> before disconnecting 
        or reloading your script to properly clean up connections.
      </InfoBox>
    </div>
  );
}

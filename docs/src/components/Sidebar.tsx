"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState } from "react";

interface NavItem {
  title: string;
  href: string;
}

interface NavSection {
  title: string;
  items: NavItem[];
}

const navigation: NavSection[] = [
  {
    title: "Introduction",
    items: [
      { title: "Getting Started", href: "/" },
      { title: "Installation", href: "/installation" },
      { title: "Structuring", href: "/structuring" },
    ],
  },
  {
    title: "Core",
    items: [
      { title: "Library", href: "/core/library" },
      { title: "Common Properties", href: "/core/common-properties" },
      { title: "SaveManager", href: "/core/save-manager" },
      { title: "ThemeManager", href: "/core/theme-manager" },
    ],
  },
  {
    title: "Structure",
    items: [
      { title: "Window", href: "/structure/window" },
      { title: "Tabs", href: "/structure/tabs" },
      { title: "Sections", href: "/structure/sections" },
      { title: "Tabboxes", href: "/structure/tabboxes" },
      { title: "DependencyBox", href: "/structure/dependency" },
    ],
  },
  {
    title: "UI Elements",
    items: [
      { title: "Labels", href: "/elements/labels" },
      { title: "Buttons", href: "/elements/buttons" },
      { title: "Toggles", href: "/elements/toggles" },
      { title: "Checkboxes", href: "/elements/checkboxes" },
      { title: "Sliders", href: "/elements/sliders" },
      { title: "Dropdowns", href: "/elements/dropdowns" },
      { title: "Textboxes", href: "/elements/textboxes" },
      { title: "Color Pickers", href: "/elements/color-pickers" },
      { title: "Keybinds", href: "/elements/keybinds" },
      { title: "Dividers", href: "/elements/dividers" },
      { title: "Images", href: "/elements/images" },
      { title: "Viewports", href: "/elements/viewports" },
      { title: "Passthrough", href: "/elements/passthrough" },
    ],
  },
];

export function Sidebar() {
  const pathname = usePathname();
  const [searchQuery, setSearchQuery] = useState("");

  const filteredNavigation = navigation.map((section) => ({
    ...section,
    items: section.items.filter((item) =>
      item.title.toLowerCase().includes(searchQuery.toLowerCase())
    ),
  })).filter((section) => section.items.length > 0);

  return (
    <aside className="fixed left-0 top-0 h-screen w-64 bg-[#111111] border-r border-[#2d2d32] flex flex-col">
      {/* Logo */}
      <div className="p-4 border-b border-[#2d2d32]">
        <Link href="/" className="flex items-center gap-2">
          <div className="w-8 h-8 rounded-lg bg-[#00c864] flex items-center justify-center">
            <span className="text-black font-bold text-lg">S</span>
          </div>
          <span className="font-semibold text-lg text-white">Seisen UI</span>
        </Link>
      </div>

      {/* Search */}
      <div className="p-3">
        <div className="relative">
          <input
            type="text"
            placeholder="Search..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full px-3 py-2 pl-9 bg-[#1a1a1e] border border-[#2d2d32] rounded-lg text-sm text-white placeholder-[#666666] focus:outline-none focus:border-[#00c864] transition-colors"
          />
          <svg
            className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-[#666666]"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
            />
          </svg>
        </div>
      </div>

      {/* Navigation */}
      <nav className="flex-1 overflow-y-auto px-3 py-2">
        {filteredNavigation.map((section) => (
          <div key={section.title} className="mb-4">
            <h3 className="px-3 mb-1 text-xs font-semibold text-[#666666] uppercase tracking-wider">
              {section.title}
            </h3>
            <ul className="space-y-0.5">
              {section.items.map((item) => {
                const isActive = pathname === item.href;
                return (
                  <li key={item.href}>
                    <Link
                      href={item.href}
                      className={`block px-3 py-1.5 rounded-md text-sm transition-colors ${
                        isActive
                          ? "bg-[#00c864]/10 text-[#00c864] border-l-2 border-[#00c864]"
                          : "text-[#a0a0a0] hover:text-white hover:bg-[#1a1a1e]"
                      }`}
                    >
                      {item.title}
                    </Link>
                  </li>
                );
              })}
            </ul>
          </div>
        ))}
      </nav>

      {/* Footer */}
      <div className="p-4 border-t border-[#2d2d32]">
        <a
          href="https://github.com/Ken-884/Seisen-Library"
          target="_blank"
          rel="noopener noreferrer"
          className="flex items-center gap-2 text-sm text-[#666666] hover:text-white transition-colors"
        >
          <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
            <path
              fillRule="evenodd"
              d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z"
              clipRule="evenodd"
            />
          </svg>
          GitHub
        </a>
      </div>
    </aside>
  );
}

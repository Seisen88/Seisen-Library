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
  const [theme, setTheme] = useState<"dark" | "light">("dark");

  // Load theme on mount
  useState(() => {
    if (typeof window !== "undefined") {
      const savedTheme = localStorage.getItem("theme") as "dark" | "light" || "dark";
      setTheme(savedTheme);
      document.documentElement.setAttribute("data-theme", savedTheme);
    }
  });

  const toggleTheme = () => {
    const newTheme = theme === "dark" ? "light" : "dark";
    setTheme(newTheme);
    localStorage.setItem("theme", newTheme);
    document.documentElement.setAttribute("data-theme", newTheme);
  };

  const filteredNavigation = navigation.map((section) => ({
    ...section,
    items: section.items.filter((item) =>
      item.title.toLowerCase().includes(searchQuery.toLowerCase())
    ),
  })).filter((section) => section.items.length > 0);

  return (
    <aside className="fixed left-0 top-0 h-screen w-64 bg-[var(--bg-secondary)] border-r border-[var(--border)] flex flex-col z-50 transition-colors duration-200">
      {/* Logo */}
      <div className="p-4 pl-6 border-b border-[var(--border)]">
        <Link href="/" className="flex items-center gap-2">
          <span className="font-bold text-xl text-[var(--text-primary)]">SeisenUI</span>
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
            className="w-full px-3 py-2 pl-9 bg-[var(--bg-tertiary)] border border-[var(--border)] rounded-lg text-sm text-[var(--text-primary)] placeholder-[var(--text-muted)] focus:outline-none focus:border-[var(--accent)] transition-colors"
          />
          <svg
            className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-[var(--text-muted)]"
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
      <nav className="flex-1 overflow-y-auto px-3 py-2 scrollbar-thin">
        {filteredNavigation.map((section) => (
          <div key={section.title} className="mb-6">
            <h3 className="px-3 mb-2 text-xs font-semibold text-[var(--text-muted)] uppercase tracking-wider">
              {section.title}
            </h3>
            <ul className="space-y-0.5">
              {section.items.map((item) => {
                const isActive = pathname === item.href;
                return (
                  <li key={item.href}>
                    <Link
                      href={item.href}
                      className={`block px-3 py-1.5 rounded-md text-sm transition-all duration-200 ${
                        isActive
                          ? "bg-[var(--accent)]/10 text-[var(--accent)] font-medium"
                          : "text-[var(--text-secondary)] hover:text-[var(--text-primary)] hover:bg-[var(--bg-tertiary)]"
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
      <div className="p-4 border-t border-[var(--border)] flex items-center justify-between">
        <a
          href="https://github.com/Ken-884/Seisen-Library"
          target="_blank"
          rel="noopener noreferrer"
          className="text-[var(--text-muted)] hover:text-[var(--text-primary)] transition-colors p-2 rounded-md hover:bg-[var(--bg-tertiary)]"
          title="GitHub"
        >
          <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
            <path
              fillRule="evenodd"
              d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z"
              clipRule="evenodd"
            />
          </svg>
        </a>

        <button
          onClick={toggleTheme}
          className="text-[var(--text-muted)] hover:text-[var(--text-primary)] transition-colors p-2 rounded-md hover:bg-[var(--bg-tertiary)]"
          title="Toggle Theme"
        >
          {theme === "dark" ? (
             /* Sun Icon for Dark Mode */
            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z"
              />
            </svg>
          ) : (
            /* Moon Icon for Light Mode */
            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"
              />
            </svg>
          )}
        </button>
      </div>
    </aside>
  );
}

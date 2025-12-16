import React from "react";
import { Archive } from "./Archive";
import { BellOff } from "./BellOff";
import { HelpCircle } from "./HelpCircle";
import { Package } from "./Package";
import { PlusCircle } from "./PlusCircle";

interface MenuItem {
  id: string;
  icon: React.ComponentType<{ className?: string }>;
  title: string;
  description: string;
  shortcut: string;
  disabled?: boolean;
}

export const Menu = (): JSX.Element => {
  const menuItems: MenuItem[] = [
    {
      id: "archive",
      icon: Archive,
      title: "Archiviere Chat",
      description:
        "Archivierte Benachrichtigungen sind inaktiv. Der Chat wird in 12 Monaten gelöscht.",
      shortcut: "⇧A",
      disabled: false,
    },
    {
      id: "mute",
      icon: BellOff,
      title: "Stummschalten",
      description: "Deaktiviere Benachrichtigungen für diesen Chat.",
      shortcut: "⇧Ö",
      disabled: true,
    },
    {
      id: "help",
      icon: HelpCircle,
      title: "Hilfe Anfragen",
      description:
        "Eskaliere den Fall intern oder extern ohne den Datenschutz zu vernachlässigen.",
      shortcut: "⇧Ä",
      disabled: true,
    },
  ];

  const secondaryMenuItems: MenuItem[] = [
    {
      id: "invite",
      icon: PlusCircle,
      title: "Weitere Personen einladen",
      description:
        "Wer eingeladen werden kann, hängt von den Admin-Einstellungen ab.",
      shortcut: "⇧I",
      disabled: true,
    },
    {
      id: "summarize",
      icon: Package,
      title: "Chat Zusammenfassen",
      description:
        "Spare Zeit, mit Hilfe unseres vollends Datenschutzkonformen KI Workflows.",
      shortcut: "⇧Ü",
      disabled: true,
    },
  ];

  return (
    <nav
      className="flex flex-col w-[301px] items-start pt-[var(--size-space-200)] pr-[var(--size-space-200)] pb-[var(--size-space-200)] pl-[var(--size-space-200)] relative bg-color-background-default-default rounded-[var(--size-radius-200)] overflow-hidden border-2 border-solid border-[#cc1e1c]"
      role="menu"
      aria-label="Chatraum Einstellungen"
    >
      <header className="flex flex-col items-start pt-[var(--size-space-200)] pr-[var(--size-space-400)] pb-[var(--size-space-100)] pl-[var(--size-space-400)] self-stretch w-full relative flex-[0_0_auto]">
        <p className="mt-[-1.00px] font-body-small font-[number:var(--body-small-font-weight)] text-color-text-default-secondary text-[length:var(--body-small-font-size)] leading-[var(--body-small-line-height)] relative self-stretch tracking-[var(--body-small-letter-spacing)] [font-style:var(--body-small-font-style)]">
          Jeder Raum individuell anpassbar
        </p>

        <h1 className="font-body-strong font-[number:var(--body-strong-font-weight)] text-[#000000e6] text-[length:var(--body-strong-font-size)] leading-[var(--body-strong-line-height)] relative self-stretch tracking-[var(--body-strong-letter-spacing)] [font-style:var(--body-strong-font-style)]">
          Chatraum Einstellungen
        </h1>
      </header>

      <div className="flex flex-col items-center justify-center pt-[var(--size-space-200)] pr-[var(--size-space-400)] pb-[var(--size-space-200)] pl-[var(--size-space-400)] self-stretch w-full relative flex-[0_0_auto]">
        <hr className="relative self-stretch w-full h-px bg-[#cc1e1c26] border-0" />
      </div>

      <div className="flex flex-col items-start self-stretch w-full rounded-lg overflow-hidden relative flex-[0_0_auto]">
        {menuItems.map((item, index) => {
          const IconComponent = item.icon;
          return (
            <button
              key={item.id}
              className={`flex items-start gap-[var(--size-space-300)] pt-[var(--size-space-300)] pr-[var(--size-space-400)] pb-[var(--size-space-300)] pl-[var(--size-space-400)] rounded-[var(--radius-radius-md)] overflow-hidden relative self-stretch w-full flex-[0_0_auto] ${index === 0 ? "w-[285px]" : ""}`}
              role="menuitem"
              aria-disabled={item.disabled}
              disabled={item.disabled}
            >
              <IconComponent
                className="!relative !w-5 !h-5"
                aria-hidden="true"
              />
              <div className="flex flex-col items-start gap-[var(--size-space-100)] relative flex-1 grow">
                <div className="flex items-center justify-between relative self-stretch w-full flex-[0_0_auto]">
                  <span
                    className={`${item.disabled ? "text-color-text-disabled-default" : "text-color-text-default-default"} relative flex-1 mt-[-1.00px] font-body-base font-[number:var(--body-base-font-weight)] text-[length:var(--body-base-font-size)] tracking-[var(--body-base-letter-spacing)] leading-[var(--body-base-line-height)] [font-style:var(--body-base-font-style)]`}
                  >
                    {item.title}
                  </span>

                  <kbd className="inline-flex items-center justify-end rounded-lg relative flex-[0_0_auto]">
                    <span className="relative w-fit mt-[-1.00px] font-single-line-body-base font-[number:var(--single-line-body-base-font-weight)] text-color-text-default-default text-[length:var(--single-line-body-base-font-size)] tracking-[var(--single-line-body-base-letter-spacing)] leading-[var(--single-line-body-base-line-height)] whitespace-nowrap [font-style:var(--single-line-body-base-font-style)]">
                      {item.shortcut}
                    </span>
                  </kbd>
                </div>

                <p
                  className={`${item.disabled ? "text-color-text-disabled-default" : "text-color-text-default-secondary"} relative self-stretch font-body-small font-[number:var(--body-small-font-weight)] text-[length:var(--body-small-font-size)] tracking-[var(--body-small-letter-spacing)] leading-[var(--body-small-line-height)] [font-style:var(--body-small-font-style)]`}
                >
                  {item.description}
                </p>
              </div>
            </button>
          );
        })}
      </div>

      <div className="flex flex-col items-center justify-center pt-[var(--size-padding-sm)] pr-[var(--size-padding-lg)] pb-[var(--size-padding-sm)] pl-[var(--size-padding-lg)] relative self-stretch w-full flex-[0_0_auto] rounded-lg">
        <hr className="relative self-stretch w-full h-px bg-[#cc1e1c26] border-0" />
      </div>

      <div className="flex flex-col items-start relative self-stretch w-full flex-[0_0_auto]">
        {secondaryMenuItems.map((item, index) => {
          const IconComponent = item.icon;
          return (
            <button
              key={item.id}
              className={`flex items-start gap-[var(--size-space-300)] pt-[var(--size-space-300)] pr-[var(--size-space-400)] pb-[var(--size-space-300)] pl-[var(--size-space-400)] rounded-[var(--radius-radius-md)] overflow-hidden relative self-stretch w-full flex-[0_0_auto] ${index === 1 ? "w-[285px]" : ""}`}
              role="menuitem"
              aria-disabled={item.disabled}
              disabled={item.disabled}
            >
              <IconComponent
                className="!relative !w-5 !h-5"
                aria-hidden="true"
              />
              <div className="flex flex-col items-start gap-[var(--size-space-100)] relative flex-1 grow">
                <div className="flex items-center justify-between relative self-stretch w-full flex-[0_0_auto]">
                  <span className="text-color-text-disabled-default relative flex-1 mt-[-1.00px] font-body-base font-[number:var(--body-base-font-weight)] text-[length:var(--body-base-font-size)] tracking-[var(--body-base-letter-spacing)] leading-[var(--body-base-line-height)] [font-style:var(--body-base-font-style)]">
                    {item.title}
                  </span>

                  <kbd className="inline-flex items-center justify-end rounded-lg relative flex-[0_0_auto]">
                    <span className="relative w-fit mt-[-1.00px] font-single-line-body-base font-[number:var(--single-line-body-base-font-weight)] text-color-text-default-default text-[length:var(--single-line-body-base-font-size)] tracking-[var(--single-line-body-base-letter-spacing)] leading-[var(--single-line-body-base-line-height)] whitespace-nowrap [font-style:var(--single-line-body-base-font-style)]">
                      {item.shortcut}
                    </span>
                  </kbd>
                </div>

                <p className="text-color-text-disabled-default relative self-stretch font-body-small font-[number:var(--body-small-font-weight)] text-[length:var(--body-small-font-size)] tracking-[var(--body-small-letter-spacing)] leading-[var(--body-small-line-height)] [font-style:var(--body-small-font-style)]">
                  {item.description}
                </p>
              </div>
            </button>
          );
        })}
      </div>
    </nav>
  );
};
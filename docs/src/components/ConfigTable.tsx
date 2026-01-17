interface ConfigRow {
  property: string;
  type: string;
  default: string;
  description: string;
  required?: boolean;
}

interface ConfigTableProps {
  title?: string;
  rows: ConfigRow[];
}

export function ConfigTable({ title, rows }: ConfigTableProps) {
  return (
    <div className="my-6">
      {title && (
        <h3 className="text-lg font-semibold mb-3 text-white">{title}</h3>
      )}
      <div className="overflow-x-auto border border-[#2d2d32] rounded-lg">
        <table className="w-full !my-0">
          <thead>
            <tr className="bg-[#1a1a1e]">
              <th className="!border-0 !border-b border-[#2d2d32]">Property</th>
              <th className="!border-0 !border-b border-[#2d2d32]">Type</th>
              <th className="!border-0 !border-b border-[#2d2d32]">Default</th>
              <th className="!border-0 !border-b border-[#2d2d32]">Description</th>
            </tr>
          </thead>
          <tbody>
            {rows.map((row, index) => (
              <tr key={index} className="hover:bg-[#111111]">
                <td className="!border-0 !border-b border-[#2d2d32]">
                  <code className="text-[#00c864]">{row.property}</code>
                  {row.required && <span className="ml-1 text-red-400 text-xs">*</span>}
                </td>
                <td className="!border-0 !border-b border-[#2d2d32]">
                  <span className="text-[#bd93f9]">{row.type}</span>
                </td>
                <td className="!border-0 !border-b border-[#2d2d32]">
                  <code className="text-[#f1fa8c]">{row.default}</code>
                </td>
                <td className="!border-0 !border-b border-[#2d2d32] text-[#a0a0a0]">
                  {row.description}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

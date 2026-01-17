interface PageHeaderProps {
  title: string;
  description: string;
}

export function PageHeader({ title, description }: PageHeaderProps) {
  return (
    <div className="mb-8">
      <h1 className="text-3xl font-bold text-white mb-2">{title}</h1>
      <p className="text-lg text-[#a0a0a0]">{description}</p>
    </div>
  );
}

interface InfoBoxProps {
  type?: "info" | "warning" | "tip";
  children: React.ReactNode;
}

export function InfoBox({ type = "info", children }: InfoBoxProps) {
  const styles = {
    info: "bg-blue-500/10 border-blue-500/50 text-blue-200",
    warning: "bg-yellow-500/10 border-yellow-500/50 text-yellow-200",
    tip: "bg-green-500/10 border-green-500/50 text-green-200",
  };

  const icons = {
    info: (
      <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
      </svg>
    ),
    warning: (
      <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
      </svg>
    ),
    tip: (
      <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z" />
      </svg>
    ),
  };

  return (
    <div className={`flex gap-3 p-4 rounded-lg border ${styles[type]} my-4`}>
      <div className="flex-shrink-0">{icons[type]}</div>
      <div className="text-sm">{children}</div>
    </div>
  );
}

interface MethodCardProps {
  name: string;
  description: string;
  params?: string;
  returns?: string;
}

export function MethodCard({ name, description, params, returns }: MethodCardProps) {
  return (
    <div className="border border-[#2d2d32] rounded-lg p-4 my-3 hover:border-[#00c864]/50 transition-colors">
      <h4 className="font-mono text-[#00c864] font-semibold mb-2">{name}</h4>
      <p className="text-sm text-[#a0a0a0] mb-2">{description}</p>
      {params && (
        <div className="text-xs text-[#666666]">
          <span className="text-[#ff79c6]">Parameters:</span> {params}
        </div>
      )}
      {returns && (
        <div className="text-xs text-[#666666]">
          <span className="text-[#8be9fd]">Returns:</span> {returns}
        </div>
      )}
    </div>
  );
}

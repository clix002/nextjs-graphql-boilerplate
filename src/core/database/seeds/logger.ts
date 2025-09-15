type LogLevel = "info" | "success" | "error" | "warn";

function formatMessage(level: LogLevel, message: string): string {
  const timestamp = new Date().toISOString().split("T")[1].split(".")[0];
  const icons = {
    info: "🔍",
    success: "✅",
    error: "❌",
    warn: "⚠️",
  };

  return `[${timestamp}] ${icons[level]} ${message}`;
}

export const Logger = {
  info: (message: string): void => {
    console.log(formatMessage("info", message));
  },

  success: (message: string): void => {
    console.log(formatMessage("success", message));
  },

  error: (message: string): void => {
    console.error(formatMessage("error", message));
  },

  warn: (message: string): void => {
    console.warn(formatMessage("warn", message));
  },

  step: (step: string, message: string): void => {
    console.log(`\n📋 ${step}: ${message}`);
  },
};

export default Logger;

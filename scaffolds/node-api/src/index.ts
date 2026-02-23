/**
 * {{PROJECT_NAME}} - {{DESCRIPTION}}
 * @author {{AUTHOR}}
 */

export function main(): void {
  console.log("Hello from {{PROJECT_NAME}}");
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main();
}

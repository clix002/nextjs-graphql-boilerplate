import { UserForm } from "./user-form";
import { UserListServer } from "./user-list-server";

export default function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      <div className="container mx-auto px-4 py-8">
        <header className="text-center mb-12">
          <h1 className="text-5xl font-bold text-gray-800 mb-4">
            Sistema de Usuarios
          </h1>
          <p className="text-xl text-gray-600">
            Comparación entre Server Components y Client Components
          </p>
        </header>

        <div className="grid gap-12">
          <UserListServer />
          <UserForm />
        </div>
      </div>
    </div>
  );
}

import { getClient } from "@/client/apollo/apollo-server-client";
import { GetAllSysUsersDocument } from "@/client/apollo/generated/graphql";
import type { GetAllSysUsersQuery } from "@/core/api/graphql/generated/backend";

export async function UserListServer() {
  const { data: allUsers } = await getClient().query<GetAllSysUsersQuery>({
    query: GetAllSysUsersDocument,
  });
  const users = allUsers?.getAllSysUsers ?? [];

  return (
    <div className="bg-white rounded-2xl shadow-xl border border-green-200 overflow-hidden">
      <div className="bg-gradient-to-r from-green-500 to-emerald-600 px-8 py-6">
        <h2 className="text-2xl font-bold text-white flex items-center gap-3">
          <div className="w-8 h-8 bg-white/20 rounded-lg flex items-center justify-center">
            🚀
          </div>
          Server Component - Solo Lectura
        </h2>
        <p className="text-green-100 mt-2">
          Datos precargados desde el servidor
        </p>
      </div>

      <div className="p-8">
        {users.length === 0 ? (
          <div className="text-center py-12">
            <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
              👥
            </div>
            <p className="text-gray-500 text-lg">No hay usuarios registrados</p>
          </div>
        ) : (
          <div className="grid gap-4">
            {users.map((user) => (
              <div
                key={user.id}
                className="bg-gradient-to-r from-gray-50 to-gray-100 rounded-xl p-6 border border-gray-200 hover:shadow-md transition-shadow"
              >
                <div className="flex items-center gap-4">
                  <div className="w-12 h-12 bg-gradient-to-br from-green-400 to-green-600 rounded-full flex items-center justify-center text-white font-bold text-lg">
                    {user.firstName.charAt(0).toUpperCase()}
                  </div>
                  <div className="flex-1">
                    <h3 className="font-semibold text-gray-900 text-lg">
                      {user.firstName} {user.lastName}
                    </h3>
                    <p className="text-gray-600">{user.email}</p>
                  </div>
                  <div className="text-green-600 font-medium">✅ Activo</div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Info sobre Server Component */}
      <div className="bg-gradient-to-r from-green-50 to-emerald-50 border-t border-green-200 px-8 py-6">
        <h3 className="text-lg font-semibold mb-4 text-green-800 flex items-center gap-2">
          <span className="text-xl">ℹ️</span>
          Características del Server Component
        </h3>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div className="flex items-center gap-3">
            <div className="w-8 h-8 bg-green-100 rounded-lg flex items-center justify-center">
              📖
            </div>
            <div>
              <p className="font-medium text-green-800">Solo Lectura</p>
              <p className="text-sm text-green-600">Apollo Server Query</p>
            </div>
          </div>
          <div className="flex items-center gap-3">
            <div className="w-8 h-8 bg-green-100 rounded-lg flex items-center justify-center">
              ⚡
            </div>
            <div>
              <p className="font-medium text-green-800">Sin Recargas</p>
              <p className="text-sm text-green-600">Ejecuta en servidor</p>
            </div>
          </div>
          <div className="flex items-center gap-3">
            <div className="w-8 h-8 bg-green-100 rounded-lg flex items-center justify-center">
              🚀
            </div>
            <div>
              <p className="font-medium text-green-800">Rápido</p>
              <p className="text-sm text-green-600">Datos precargados</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

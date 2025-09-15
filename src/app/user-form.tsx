"use client";

import { useMutation, useQuery } from "@apollo/client/react";
import { zodResolver } from "@hookform/resolvers/zod";
import { useState } from "react";
import { useForm } from "react-hook-form";
import {
  CreateSysUserDocument,
  DeleteSysUserByIdDocument,
  GetAllSysUsersDocument,
  GetSysUserByIdDocument,
  type SysUser,
  UpdateSysUserByIdDocument,
} from "@/client/apollo/generated/graphql";
import { Button } from "@/client/components/ui/button";
import {
  type CreateSysUserInput as CreateUserFormData,
  CreateSysUserSchema as CreateUserFormSchema,
  type UpdateSysUserInput as UpdateUserFormData,
  UpdateSysUserSchema as UpdateUserFormSchema,
} from "@/shared/domain/schemas/sys-user/sys-user.schemas";

export function UserForm() {
  const [selectedUserId, setSelectedUserId] = useState<string>("");

  const { data: allUsers, loading: loadingUsers } = useQuery(
    GetAllSysUsersDocument,
  );
  const { data: _selectedUser } = useQuery(GetSysUserByIdDocument, {
    variables: { id: selectedUserId },
    skip: !selectedUserId,
  });

  const [createUser] = useMutation(CreateSysUserDocument, {
    update: (cache, { data }) => {
      if (data?.createSysUser) {
        const existingUsers = cache.readQuery({
          query: GetAllSysUsersDocument,
        });

        cache.writeQuery({
          query: GetAllSysUsersDocument,
          data: {
            getAllSysUsers: [
              ...(existingUsers?.getAllSysUsers ?? []),
              data.createSysUser,
            ],
          },
        });
      }
    },
    onCompleted: () => {
      resetForm();
    },
    onError: (error) => {
      console.error("Error creating user:", error);
    },
  });

  const [updateUser] = useMutation(UpdateSysUserByIdDocument, {
    onCompleted: () => {
      resetForm();
      setSelectedUserId("");
    },
    onError: (error) => {
      console.error("Error updating user:", error);
    },
  });

  const [deleteUser] = useMutation(DeleteSysUserByIdDocument, {
    update: (cache, { data }) => {
      if (data?.deleteSysUserById) {
        const existingUsers = cache.readQuery({
          query: GetAllSysUsersDocument,
        });

        cache.writeQuery({
          query: GetAllSysUsersDocument,
          data: {
            getAllSysUsers:
              existingUsers?.getAllSysUsers.filter(
                (user) => user.id !== data.deleteSysUserById.id,
              ) ?? [],
          },
        });
      }
    },
    onCompleted: () => {
      setSelectedUserId("");
    },
    onError: (error) => {
      console.error("Error deleting user:", error);
    },
  });

  const createForm = useForm<CreateUserFormData>({
    resolver: zodResolver(CreateUserFormSchema),
    defaultValues: {
      firstName: "",
      lastName: "",
      email: "",
    },
  });

  const updateForm = useForm<UpdateUserFormData>({
    resolver: zodResolver(UpdateUserFormSchema),
    defaultValues: {
      firstName: "",
      lastName: "",
      email: "",
    },
  });

  const resetForm = () => {
    createForm.reset();
    updateForm.reset();
  };

  const handleCreateSubmit = async (data: CreateUserFormData) => {
    await createUser({
      variables: { input: data },
    });
  };

  const handleUpdateSubmit = async (data: UpdateUserFormData) => {
    if (!selectedUserId) return;

    await updateUser({
      variables: {
        id: selectedUserId,
        input: data,
      },
    });
  };

  const handleEdit = (user: SysUser) => {
    setSelectedUserId(user.id);
    updateForm.reset({
      firstName: user.firstName,
      lastName: user.lastName || undefined,
      email: user.email || undefined,
    });
  };

  const handleDelete = async (id: string) => {
    if (confirm("¿Estás seguro de que quieres eliminar este usuario?")) {
      await deleteUser({ variables: { id } });
    }
  };

  const handleCancel = () => {
    resetForm();
    setSelectedUserId("");
  };

  const users = allUsers?.getAllSysUsers ?? [];
  const isEditing = !!selectedUserId;

  return (
    <div className="bg-white rounded-2xl shadow-xl border border-blue-200 overflow-hidden">
      <div className="bg-gradient-to-r from-blue-500 to-indigo-600 px-8 py-6">
        <h2 className="text-2xl font-bold text-white flex items-center gap-3">
          <div className="w-8 h-8 bg-white/20 rounded-lg flex items-center justify-center">
            ⚡
          </div>
          User Form con React Hook Form + Zod
        </h2>
        <p className="text-blue-100 mt-2">Validación en tiempo real con Zod</p>
      </div>

      <div className="p-8">
        {/* Form */}
        <div className="bg-gradient-to-r from-blue-50 to-indigo-50 rounded-xl p-6 mb-8 border border-blue-200">
          <h3 className="text-xl font-semibold mb-6 text-gray-800 flex items-center gap-2">
            <span className="text-2xl">{isEditing ? "✏️" : "➕"}</span>
            {isEditing ? "Editar Usuario" : "Crear Usuario"}
          </h3>

          {isEditing ? (
            <form
              onSubmit={updateForm.handleSubmit(handleUpdateSubmit)}
              className="space-y-4"
            >
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div>
                  <label
                    htmlFor="firstName"
                    className="block text-sm font-medium mb-2"
                  >
                    Nombre
                  </label>
                  <input
                    {...updateForm.register("firstName")}
                    type="text"
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all text-gray-900"
                    placeholder="Ingresa el nombre"
                  />
                  {updateForm.formState.errors.firstName && (
                    <p className="text-red-500 text-sm mt-1">
                      {updateForm.formState.errors.firstName.message}
                    </p>
                  )}
                </div>

                <div>
                  <label
                    htmlFor="lastName"
                    className="block text-sm font-medium mb-2"
                  >
                    Apellido
                  </label>
                  <input
                    {...updateForm.register("lastName")}
                    type="text"
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all text-gray-900"
                    placeholder="Ingresa el apellido"
                  />
                  {updateForm.formState.errors.lastName && (
                    <p className="text-red-500 text-sm mt-1">
                      {updateForm.formState.errors.lastName.message}
                    </p>
                  )}
                </div>

                <div>
                  <label
                    htmlFor="email"
                    className="block text-sm font-medium mb-2"
                  >
                    Email
                  </label>
                  <input
                    {...updateForm.register("email")}
                    type="email"
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all text-gray-900"
                    placeholder="ejemplo@correo.com"
                  />
                  {updateForm.formState.errors.email && (
                    <p className="text-red-500 text-sm mt-1">
                      {updateForm.formState.errors.email.message}
                    </p>
                  )}
                </div>
              </div>

              <div className="flex gap-3">
                <Button
                  type="submit"
                  disabled={updateForm.formState.isSubmitting}
                >
                  <span className="text-lg">💾</span>
                  {updateForm.formState.isSubmitting
                    ? "Actualizando..."
                    : "Actualizar"}
                </Button>

                <Button type="button" onClick={handleCancel} variant="outline">
                  <span className="text-lg">❌</span>
                  Cancelar
                </Button>
              </div>
            </form>
          ) : (
            <form
              onSubmit={createForm.handleSubmit(handleCreateSubmit)}
              className="space-y-4"
            >
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div>
                  <label
                    htmlFor="firstName"
                    className="block text-sm font-medium mb-2"
                  >
                    Nombre
                  </label>
                  <input
                    {...createForm.register("firstName")}
                    type="text"
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all text-gray-900"
                    placeholder="Ingresa el nombre"
                  />
                  {createForm.formState.errors.firstName && (
                    <p className="text-red-500 text-sm mt-1">
                      {createForm.formState.errors.firstName.message}
                    </p>
                  )}
                </div>

                <div>
                  <label
                    htmlFor="lastName"
                    className="block text-sm font-medium mb-2"
                  >
                    Apellido
                  </label>
                  <input
                    {...createForm.register("lastName")}
                    type="text"
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all text-gray-900"
                    placeholder="Ingresa el apellido"
                  />
                  {createForm.formState.errors.lastName && (
                    <p className="text-red-500 text-sm mt-1">
                      {createForm.formState.errors.lastName.message}
                    </p>
                  )}
                </div>

                <div>
                  <label
                    htmlFor="email"
                    className="block text-sm font-medium mb-2"
                  >
                    Email
                  </label>
                  <input
                    {...createForm.register("email")}
                    type="email"
                    className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all text-gray-900"
                    placeholder="ejemplo@correo.com"
                  />
                  {createForm.formState.errors.email && (
                    <p className="text-red-500 text-sm mt-1">
                      {createForm.formState.errors.email.message}
                    </p>
                  )}
                </div>
              </div>

              <div className="flex gap-3">
                <Button
                  type="submit"
                  disabled={createForm.formState.isSubmitting}
                >
                  <span className="text-lg">➕</span>
                  {createForm.formState.isSubmitting ? "Creando..." : "Crear"}
                </Button>
              </div>
            </form>
          )}
        </div>

        {/* Users List */}
        <div className="bg-gradient-to-r from-gray-50 to-blue-50 rounded-xl border border-gray-200">
          <div className="p-6 border-b border-gray-200">
            <h3 className="text-xl font-semibold text-gray-800 flex items-center gap-2">
              <span className="text-2xl">👥</span>
              Lista de Usuarios
            </h3>
          </div>

          {loadingUsers ? (
            <div className="p-6 text-center">Cargando usuarios...</div>
          ) : users.length === 0 ? (
            <div className="p-6 text-center text-gray-500">
              No hay usuarios registrados
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Nombre
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Apellido
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Email
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Acciones
                    </th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-200">
                  {users.map((user: SysUser) => (
                    <tr
                      key={user.id}
                      className={selectedUserId === user.id ? "bg-blue-50" : ""}
                    >
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                        {user.firstName}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {user.lastName}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {user.email}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium space-x-2">
                        <Button
                          type="button"
                          onClick={() => handleEdit(user)}
                          variant="outline"
                          size="sm"
                        >
                          ✏️ Editar
                        </Button>
                        <Button
                          type="button"
                          onClick={() => handleDelete(user.id)}
                          variant="destructive"
                          size="sm"
                        >
                          🗑️ Eliminar
                        </Button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

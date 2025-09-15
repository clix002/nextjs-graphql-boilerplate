// "use client";

// import { useMutation, useQuery } from "@apollo/client/react";
// import { useState } from "react";
// import {
//   CreateUserDocument,
//   DeleteUserDocument,
//   GetAllUsersDocument,
//   GetUserByIdDocument,
//   type SysUser,
//   UpdateUserDocument,
// } from "@/client/apollo/generated/graphql";

// interface UserFormData {
//   firstName: string;
//   lastName: string;
//   email: string;
// }

// export function UserCRUD() {
//   const [selectedUserId, setSelectedUserId] = useState<string>("");
//   const [formData, setFormData] = useState<UserFormData>({
//     firstName: "",
//     lastName: "",
//     email: "",
//   });

//   const { data: allUsers, loading: loadingUsers } =
//     useQuery(GetAllUsersDocument);
//   const { data: selectedUser } = useQuery(GetUserByIdDocument, {
//     variables: { id: selectedUserId },
//     skip: !selectedUserId,
//   });

//   const [createUser] = useMutation(CreateUserDocument, {
//     onCompleted: () => {
//       resetForm();
//     },
//   });

//   const [updateUser] = useMutation(UpdateUserDocument, {
//     onCompleted: () => {
//       resetForm();
//       setSelectedUserId("");
//     },
//   });

//   const [deleteUser] = useMutation(DeleteUserDocument, {
//     onCompleted: () => {
//       setSelectedUserId("");
//     },
//   });

//   const resetForm = () => {
//     setFormData({ firstName: "", lastName: "", email: "" });
//   };

//   const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
//     const { name, value } = e.target;
//     setFormData((prev) => ({ ...prev, [name]: value }));
//   };

//   const handleSubmit = async (e: React.FormEvent) => {
//     e.preventDefault();

//     if (selectedUserId) {
//       await updateUser({
//         variables: {
//           id: selectedUserId,
//           input: formData,
//         },
//       });
//     } else {
//       await createUser({
//         variables: {
//           input: formData,
//         },
//       });
//     }
//   };

//   const handleEdit = (user: SysUser) => {
//     setSelectedUserId(user.id);
//     setFormData({
//       firstName: user.firstName,
//       lastName: user.lastName || "",
//       email: user.email,
//     });
//   };

//   const handleDelete = async (id: string) => {
//     if (confirm("¿Estás seguro de que quieres eliminar este usuario?")) {
//       await deleteUser({ variables: { id } });
//     }
//   };

//   const handleCancel = () => {
//     resetForm();
//     setSelectedUserId("");
//   };

//   const users = allUsers?.getAllUsers ?? [];

//   return (
//     <div className="bg-white rounded-2xl shadow-xl border border-blue-200 overflow-hidden">
//       <div className="bg-gradient-to-r from-blue-500 to-indigo-600 px-8 py-6">
//         <h2 className="text-2xl font-bold text-white flex items-center gap-3">
//           <div className="w-8 h-8 bg-white/20 rounded-lg flex items-center justify-center">
//             ⚡
//           </div>
//           Client Component - CRUD Completo
//         </h2>
//         <p className="text-blue-100 mt-2">
//           Interactividad completa con Apollo Client
//         </p>
//       </div>

//       <div className="p-8">
//         {/* Form */}
//         <div className="bg-gradient-to-r from-blue-50 to-indigo-50 rounded-xl p-6 mb-8 border border-blue-200">
//           <h3 className="text-xl font-semibold mb-6 text-gray-800 flex items-center gap-2">
//             <span className="text-2xl">{selectedUserId ? "✏️" : "➕"}</span>
//             {selectedUserId ? "Editar Usuario" : "Crear Usuario"}
//           </h3>

//           <form onSubmit={handleSubmit} className="space-y-4">
//             <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
//               <div>
//                 <label
//                   htmlFor="firstName"
//                   className="block text-sm font-medium mb-2"
//                 >
//                   Nombre
//                 </label>
//                 <input
//                   type="text"
//                   id="firstName"
//                   name="firstName"
//                   value={formData.firstName}
//                   onChange={handleInputChange}
//                   required
//                   className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all text-gray-900"
//                   placeholder="Ingresa el nombre"
//                 />
//               </div>

//               <div>
//                 <label
//                   htmlFor="lastName"
//                   className="block text-sm font-medium mb-2"
//                 >
//                   Apellido
//                 </label>
//                 <input
//                   type="text"
//                   id="lastName"
//                   name="lastName"
//                   value={formData.lastName}
//                   onChange={handleInputChange}
//                   className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all text-gray-900"
//                   placeholder="Ingresa el apellido"
//                 />
//               </div>

//               <div>
//                 <label
//                   htmlFor="email"
//                   className="block text-sm font-medium mb-2"
//                 >
//                   Email
//                 </label>
//                 <input
//                   type="email"
//                   id="email"
//                   name="email"
//                   value={formData.email}
//                   onChange={handleInputChange}
//                   required
//                   className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all text-gray-900"
//                   placeholder="ejemplo@correo.com"
//                 />
//               </div>
//             </div>

//             <div className="flex gap-3">
//               <button
//                 type="submit"
//                 className="px-6 py-3 bg-gradient-to-r from-blue-500 to-blue-600 text-white rounded-lg hover:from-blue-600 hover:to-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-all font-medium flex items-center gap-2"
//               >
//                 <span className="text-lg">{selectedUserId ? "💾" : "➕"}</span>
//                 {selectedUserId ? "Actualizar" : "Crear"}
//               </button>

//               {selectedUserId && (
//                 <button
//                   type="button"
//                   onClick={handleCancel}
//                   className="px-6 py-3 bg-gradient-to-r from-gray-500 to-gray-600 text-white rounded-lg hover:from-gray-600 hover:to-gray-700 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2 transition-all font-medium flex items-center gap-2"
//                 >
//                   <span className="text-lg">❌</span>
//                   Cancelar
//                 </button>
//               )}
//             </div>
//           </form>
//         </div>

//         {/* Users List */}
//         <div className="bg-gradient-to-r from-gray-50 to-blue-50 rounded-xl border border-gray-200">
//           <div className="p-6 border-b border-gray-200">
//             <h3 className="text-xl font-semibold text-gray-800 flex items-center gap-2">
//               <span className="text-2xl">👥</span>
//               Lista de Usuarios
//             </h3>
//           </div>

//           {loadingUsers ? (
//             <div className="p-6 text-center">Cargando usuarios...</div>
//           ) : users.length === 0 ? (
//             <div className="p-6 text-center text-gray-500">
//               No hay usuarios registrados
//             </div>
//           ) : (
//             <div className="overflow-x-auto">
//               <table className="w-full">
//                 <thead className="bg-gray-50">
//                   <tr>
//                     <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
//                       Nombre
//                     </th>
//                     <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
//                       Apellido
//                     </th>
//                     <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
//                       Email
//                     </th>
//                     <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
//                       Acciones
//                     </th>
//                   </tr>
//                 </thead>
//                 <tbody className="divide-y divide-gray-200">
//                   {users.map((user) => (
//                     <tr
//                       key={user.id}
//                       className={selectedUserId === user.id ? "bg-blue-50" : ""}
//                     >
//                       <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
//                         {user.firstName}
//                       </td>
//                       <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
//                         {user.lastName}
//                       </td>
//                       <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
//                         {user.email}
//                       </td>
//                       <td className="px-6 py-4 whitespace-nowrap text-sm font-medium space-x-2">
//                         <button
//                           type="button"
//                           onClick={() => handleEdit(user as SysUser)}
//                           className="px-3 py-1 bg-blue-100 text-blue-700 rounded-lg hover:bg-blue-200 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all text-sm font-medium"
//                         >
//                           ✏️ Editar
//                         </button>
//                         <button
//                           type="button"
//                           onClick={() => handleDelete(user.id)}
//                           className="px-3 py-1 bg-red-100 text-red-700 rounded-lg hover:bg-red-200 focus:outline-none focus:ring-2 focus:ring-red-500 transition-all text-sm font-medium"
//                         >
//                           🗑️ Eliminar
//                         </button>
//                       </td>
//                     </tr>
//                   ))}
//                 </tbody>
//               </table>
//             </div>
//           )}
//         </div>

//         {/* Selected User Details */}
//         {selectedUser?.getUserById && (
//           <div className="mt-8 bg-gradient-to-r from-blue-50 to-indigo-50 p-6 rounded-xl border border-blue-200">
//             <h3 className="text-lg font-semibold mb-4 text-blue-800 flex items-center gap-2">
//               <span className="text-xl">👤</span>
//               Usuario Seleccionado
//             </h3>
//             <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
//               <div>
//                 <p className="text-sm text-gray-600">ID</p>
//                 <p className="font-medium">{selectedUser.getUserById.id}</p>
//               </div>
//               <div>
//                 <p className="text-sm text-gray-600">Nombre</p>
//                 <p className="font-medium">
//                   {selectedUser.getUserById.firstName}{" "}
//                   {selectedUser.getUserById.lastName}
//                 </p>
//               </div>
//               <div className="md:col-span-2">
//                 <p className="text-sm text-gray-600">Email</p>
//                 <p className="font-medium">{selectedUser.getUserById.email}</p>
//               </div>
//             </div>
//           </div>
//         )}
//       </div>
//     </div>
//   );
// }

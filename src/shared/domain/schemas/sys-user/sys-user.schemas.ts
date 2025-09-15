import { z } from "zod";

const firstNameField = z.string().min(1);
const lastNameField = z.string().min(1);
const emailField = z.email();

export const SysUserSchema = z.object({
  id: z.string().optional(),
  firstName: firstNameField,
  lastName: lastNameField.optional(),
  email: emailField,
});

export const CreateSysUserSchema = z.object({
  firstName: firstNameField,
  lastName: lastNameField.optional(),
  email: emailField,
});

export const UpdateSysUserSchema = z.object({
  firstName: firstNameField.optional(),
  lastName: lastNameField.optional(),
  email: emailField.optional(),
});

export type SysUserType = z.infer<typeof SysUserSchema>;
export type CreateSysUserInput = z.infer<typeof CreateSysUserSchema>;
export type UpdateSysUserInput = z.infer<typeof UpdateSysUserSchema>;

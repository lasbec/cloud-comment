import { z } from 'zod';

const sessionSchema = z.object({ authenticated: z.boolean() });

export type Session = z.infer<typeof sessionSchema>;

export async function getSession(): Promise<Session> {
  const response = await fetch('/api/session', { credentials: 'include' });
  return sessionSchema.parse(await response.json());
}

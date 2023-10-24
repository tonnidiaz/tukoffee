export {};
import { TUser, UserSchema } from "@/models/user";
declare global {
    namespace Express {
        interface Request {
            user: TUser | null;
        }

        export interface Tonics {}
    }
}

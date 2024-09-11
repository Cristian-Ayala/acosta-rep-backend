export interface JwtPayload {
  id: string;
  email: string;
  roles: string[];
  sucursal: string[];
  active: boolean;
  "https://hasura.io/jwt/claims"?: {
    "x-hasura-default-role": string;
    "x-hasura-allowed-roles": string[];
    "x-hasura-user-id": string;
    "x-hasura-user-email": string;
  };
}

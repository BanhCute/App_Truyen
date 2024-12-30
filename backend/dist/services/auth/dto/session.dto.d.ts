export declare class SessionDto {
    id: number;
    name: string;
    avatar: string | null;
    roles: string[];
    authorities: string[];
}
export declare class SessionResponseDto extends SessionDto {
    rolePicked: boolean;
}

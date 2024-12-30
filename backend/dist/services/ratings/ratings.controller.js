"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.RatingsController = void 0;
const common_1 = require("@nestjs/common");
const ratings_service_1 = require("./ratings.service");
const create_rating_dto_1 = require("./dto/create-rating.dto");
const rating_dto_1 = require("./dto/rating.dto");
const class_transformer_1 = require("class-transformer");
const swagger_1 = require("@nestjs/swagger");
const auth_utils_1 = require("../auth/auth.utils");
const update_rating_dto_1 = require("./dto/update-rating.dto");
let RatingsController = class RatingsController {
    constructor(ratingsService) {
        this.ratingsService = ratingsService;
    }
    async create(createRatingDto, req) {
        const session = (0, auth_utils_1.getSession)(req);
        const rating = await this.ratingsService.create(createRatingDto, session.id);
        return (0, class_transformer_1.plainToInstance)(rating_dto_1.default, rating);
    }
    async findAll(novelId, page, limit) {
        try {
            console.log('Request query params:', { novelId, page, limit });
            const result = novelId > 0
                ? await this.ratingsService.findAllByNovelWithUser(novelId, page, limit)
                : await this.ratingsService.findAll();
            console.log('Raw result:', JSON.stringify(result, null, 2));
            const transformedItems = result.items.map((item) => (0, class_transformer_1.plainToInstance)(rating_dto_1.default, item));
            console.log('Transformed items:', JSON.stringify(transformedItems, null, 2));
            return {
                items: transformedItems,
                meta: result.meta,
            };
        }
        catch (error) {
            console.error('Error in findAll:', error);
            console.error('Error details:', error.message);
            console.error('Error stack:', error.stack);
            return {
                items: [],
                meta: {
                    page,
                    limit,
                    total: 0,
                    totalPages: 0,
                },
            };
        }
    }
    async findAllByNovelWithUser(novelId, page, limit) {
        try {
            console.log(`Finding ratings for novel ${novelId} (page ${page}, limit ${limit})`);
            const result = await this.ratingsService.findAllByNovelWithUser(novelId, page, limit);
            console.log('Raw result:', JSON.stringify(result, null, 2));
            const transformedItems = result.items.map((item) => (0, class_transformer_1.plainToInstance)(rating_dto_1.default, item));
            console.log('Transformed items:', JSON.stringify(transformedItems, null, 2));
            return {
                items: transformedItems,
                meta: result.meta,
            };
        }
        catch (error) {
            console.error('Error in findAllByNovelWithUser:', error);
            console.error('Error details:', error.message);
            console.error('Error stack:', error.stack);
            return {
                items: [],
                meta: {
                    page,
                    limit,
                    total: 0,
                    totalPages: 0,
                },
            };
        }
    }
    async findOne(id) {
        const rating = await this.ratingsService.findOne(id);
        return (0, class_transformer_1.plainToInstance)(rating_dto_1.default, rating);
    }
    async update(id, updateRatingDto, req) {
        const session = (0, auth_utils_1.getSession)(req);
        const rating = await this.ratingsService.update(id, updateRatingDto, session.id);
        return (0, class_transformer_1.plainToInstance)(rating_dto_1.default, rating);
    }
};
exports.RatingsController = RatingsController;
__decorate([
    (0, common_1.Post)(),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_rating_dto_1.CreateRatingDto, Object]),
    __metadata("design:returntype", Promise)
], RatingsController.prototype, "create", null);
__decorate([
    (0, common_1.Get)(),
    __param(0, (0, common_1.Query)('novelId', new common_1.DefaultValuePipe(0), common_1.ParseIntPipe)),
    __param(1, (0, common_1.Query)('page', new common_1.DefaultValuePipe(1), common_1.ParseIntPipe)),
    __param(2, (0, common_1.Query)('limit', new common_1.DefaultValuePipe(10), common_1.ParseIntPipe)),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, Number, Number]),
    __metadata("design:returntype", Promise)
], RatingsController.prototype, "findAll", null);
__decorate([
    (0, common_1.Get)('novel/:novelId/with-user'),
    __param(0, (0, common_1.Param)('novelId', common_1.ParseIntPipe)),
    __param(1, (0, common_1.Query)('page', new common_1.DefaultValuePipe(1), common_1.ParseIntPipe)),
    __param(2, (0, common_1.Query)('limit', new common_1.DefaultValuePipe(10), common_1.ParseIntPipe)),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, Number, Number]),
    __metadata("design:returntype", Promise)
], RatingsController.prototype, "findAllByNovelWithUser", null);
__decorate([
    (0, common_1.Get)(':id'),
    __param(0, (0, common_1.Param)('id', common_1.ParseIntPipe)),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number]),
    __metadata("design:returntype", Promise)
], RatingsController.prototype, "findOne", null);
__decorate([
    (0, common_1.Put)(':id'),
    __param(0, (0, common_1.Param)('id', common_1.ParseIntPipe)),
    __param(1, (0, common_1.Body)()),
    __param(2, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, update_rating_dto_1.UpdateRatingDto, Object]),
    __metadata("design:returntype", Promise)
], RatingsController.prototype, "update", null);
exports.RatingsController = RatingsController = __decorate([
    (0, swagger_1.ApiTags)('ratings'),
    (0, common_1.Controller)('ratings'),
    __metadata("design:paramtypes", [ratings_service_1.RatingsService])
], RatingsController);
//# sourceMappingURL=ratings.controller.js.map
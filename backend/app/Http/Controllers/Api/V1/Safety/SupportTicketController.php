<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Safety;

use App\DTOs\Safety\CreateSupportTicketDTO;
use App\Http\Controllers\Controller;
use App\Http\Requests\V1\Safety\CreateSupportTicketRequest;
use App\Http\Resources\V1\Safety\SupportTicketResource;
use App\Services\Safety\SupportTicketService;
use App\Traits\ApiResponseTrait;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class SupportTicketController extends Controller
{
    use ApiResponseTrait;

    public function __construct(
        private readonly SupportTicketService $ticketService,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $perPage = (int) $request->query('per_page', 15);

        $tickets = $this->ticketService->getRiderTickets($userId, $perPage);

        return $this->successResponse(
            data: SupportTicketResource::collection($tickets)->response()->getData(true),
            message: 'Support tickets retrieved.'
        );
    }

    public function store(CreateSupportTicketRequest $request): JsonResponse
    {
        $dto = CreateSupportTicketDTO::fromRequest($request);
        $ticket = $this->ticketService->createTicket($dto);

        return $this->successResponse(
            data: (new SupportTicketResource($ticket))->resolve($request),
            message: 'Support ticket submitted.',
            statusCode: Response::HTTP_CREATED
        );
    }

    public function show(Request $request, int $id): JsonResponse
    {
        $userId = (int) $request->user()->id;
        $ticket = $this->ticketService->getTicketDetails($id, $userId);

        if (!$ticket) {
            return $this->errorResponse(
                message: 'Support ticket not found.',
                statusCode: Response::HTTP_NOT_FOUND,
                errorCode: 'ERR_TICKET_NOT_FOUND'
            );
        }

        return $this->successResponse(
            data: (new SupportTicketResource($ticket))->resolve($request),
            message: 'Ticket details retrieved.'
        );
    }
}
